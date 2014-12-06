amp = Lanes.Vendor.Ampersand
delegateEventSplitter = /^(\S+)\s*(.*)$/

class ViewBase

    @extended_properties = ['ui']

    # Custom datatypes for views
    dataTypes:
        element:
            compare: (a, b)-> a is b
            set: (newVal)->
                val: newVal
                type: (if newVal instanceof Element then "element" else typeof newVal)

        collection:
            compare: (currentVal, newVal)-> currentVal is newVal
            set: (newVal)->
                val: newVal
                type: (if newVal and newVal.isCollection then "collection" else typeof newVal)

    session:
        el         : "element"
        model      : "state"
        collection : "collection"
        pubSub     : "boolean"
        parent     : "object"
        subviewId  : { type: "string", setOnce: true }


    derived:
        '$el':
            deps: ['el'], cached: false
            fn: -> Lanes.$(this.el)

        root_view:
            deps: ['parent'], fn: ->
                view = this
                while view.parent
                    view = view.parent
                if view == this then null else view

        rendered:
            deps: ["el"], fn: -> !!@el

        hasData:
            deps: ["model"], fn: -> !!@model

        viewport:
            deps: ['parent'], fn:->
                this.root_view?.viewport

    namespace: "Views"

    constructor: (attrs={})->

        this.cid = _.uniqueId('view');
        attrs || (attrs = {});
        parent = attrs.parent;
        delete attrs.parent;

        this._substituteEventUI()

        Lanes.Vendor.Ampersand.State.call(this, attrs, {init: false, parent: parent})

        this.on('change:$el',   this._handleElementChange, this)
        this.on('change:model', this._onModelChange, this)

        this._parsedBindings = Lanes.Vendor.Ampersand.Bindings(this.bindings, this)

        # if ui = _.result(this,'ui')
        #     _.extend(this._ui ||

        this._initializeBindings();
        if attrs.el && !this.autoRender
            this._handleElementChange();

        this._initializeSubviews();
        this.initialize.apply(this, arguments);

        this.set(_.pick(attrs, 'model', 'collection', 'el'))

        this.render() if this.autoRender && this.template

        if !this.pubSub? # if it's unset, not true/false; default to parent or true
            this.pubSub = if this.parent?.pubSub? then this.parent.pubSub else true

        this.on('change:model',  this._onModelChange )
        this._onModelChange() if @model

        this.initializeFormBindings() if @form_bindings

        if @keyBindings
            Lanes.Views.Keys.add(this, @keyBindings, @keyScope)

        if @pubSub
            this._pubSub = new Lanes.Views.PubSub(this)


    _normalizeUIString: (uiString, ui)->
        uiString.replace(/@ui\.[a-zA-Z_$0-9]*/g, (r)->
            return ui[r.slice(4)]
        )

    _substituteEventUI: ->
        return unless @events && @ui
        for selector in _.keys(@events)
            replaced_selector = this._normalizeUIString(selector,@ui)
            if replaced_selector != selector
                @events[replaced_selector] = @events[selector]
                delete @events[selector]


    # Initialize is an empty function by default. Override it with your own
    # initialization logic.
    initialize: Lanes.emptyFn

    # **render** is the core function that your view can override, its job is
    # to populate its element (`this.el`), with the appropriate HTML.
    render: ->
        this.withRenderContext( this.renderWithTemplate )
        return this;

    withRenderContext: (fn, args...)->
        Lanes.Views.RenderContext.push( @subviewId, @model )
        returned = fn.apply(this,args)
        Lanes.Views.RenderContext.pop()
        this.onRender?()
        returned

    renderContextFree: ->
        this.renderWithTemplate();
        this


    # ## listenToAndRun
    # Shortcut for registering a listener for a model
    # and also triggering it right away.
    listenToAndRun: (object, events, handler)->
        bound = _.bind(handler, this)
        this.listenTo(object, events, bound)
        bound();

    # Shortcut for doing everything we need to do to
    # render and fully replace current root element.
    # Either define a `template` property of your view
    # or pass in a template directly.
    # The template can either be a string or a function.
    # If it's a function it will be passed the `context`
    # argument.
    renderWithTemplate: (templateArg)->
        template = templateArg || this.template;
        throw new Error('Template string or function needed.') unless template

        newDom = if _.isFunction(template)
            template.call(this)
        else if template_fn = Lanes.Templates.find(template, @namespace)
            template = template_fn( _.result(this,'templateData'))
        else template

        newDom = Lanes.Vendor.domify(newDom) if _.isString(newDom);
        parent = this.el && this.el.parentNode;
        parent.replaceChild(newDom, this.el) if parent
        if newDom.nodeName == '#document-fragment'
            throw new Error('Views can only have one root element.')
        this.el = newDom;
        return this;

    template: ->
        '<div></div>'

    templateData: ->
        { model: this.model, collection: this.collection }

    renderTemplate:(name,data={})->
        template = Lanes.Templates.find(name, @namespace)
        if template
            template(data)
        else
            Lanes.fatal( "Template #{name} doesn't exist!" )
            ''

    renderTemplateMethod: (method)->
        return null unless name = _.result(this, method)
        this.renderTemplate(name, _.result(this, "#{method}Data") || @model)


    # Remove this view by taking the element out of the DOM, and removing any
    # applicable events listeners.
    remove: ->
        parsedBindings = this._parsedBindings;
        if this.el && this.el.parentNode then this.el.parentNode.removeChild(this.el);
        if this._subviews then _.chain(this._subviews).flatten().invoke('remove');
        this.stopListening();
        # TODO: Not sure if this is actually necessary.
        # Just trying to de-reference this potentially large
        # amount of generated functions to avoid memory leaks.
        _.each(parsedBindings, (properties, modelName)->
            _.each(properties, (value, key)->
                delete parsedBindings[modelName][key];
            );
            delete parsedBindings[modelName];
        );
        this._unBindModel( @model ) if @model
        Lanes.Views.Keys.remove(this, @key_bindings, @key_scope) if @key_bindings
        this.trigger('remove', this);
        return this;

    # Change the view's element (`this.el` property), including event re-delegation.
    _handleElementChange: (element, delegate) ->
        if changes = this.changedAttributes()
            Lanes.$(changes['el']).off('.delegateEvents' + this.cid) if changes['el']
        this.bindEvents()
        this._cacheUI()
        this._applyBindingsForKey();

    _cacheUI:->
        return unless this.ui
        # store the ui hash in _uiBindings so they can be reset later
        # and so re-rendering the view will be able to find the bindings
        this._uiBindings = this.ui unless this._uiBindings

        # get the bindings result, as a function or otherwise
        bindings = _.result(this, '_uiBindings')

        # empty the ui so we don't have anything to start with
        this.ui = {};

        # bind each of the selectors
        for key, selector of bindings
            this.ui[key] = this.$(selector)


    # Sets callbacks, where `this.events` is a hash of
    #
    # *{"event selector": "callback"}*
    #
    #     {
    #       'mousedown .title':  'edit',
    #       'click .button':     'save',
    #       'click .open':       function (e) { ... }
    #     }
    #
    # pairs. Callbacks will be bound to the view, with `this` set properly.
    # Uses event delegation for efficiency.
    # Omitting the selector binds the event to `this.el`.
    # This only works for delegate-able events: not `focus`, `blur`, and
    # not `change`, `submit`, and `reset` in Internet Explorer.
    bindEvents: (events)->
        return this if (!(events || (events = _.result(this, 'events'))))
        this.unbindEvents();
        for key, method of events
            method = this[ method ] unless _.isFunction(method);
            continue unless method
            match = key.match( delegateEventSplitter )
            this.bindEvent(match[1], match[2], _.bind(method, this))

        return this;

    # Add a single event listener to the view's element (or a child element
    # using `selector`). This only works for delegate-able events: not `focus`,
    # `blur`, and not `change`, `submit`, and `reset` in Internet Explorer.
    bindEvent: (eventName, selector, listener)->
        this.$el.on(eventName + '.delegateEvents' + this.cid, selector, listener)

    # Clears all callbacks previously bound to the view with `delegateEvents`.
    # You usually don't need to use this, but may wish to if you have multiple
    # views attached to the same DOM element.
    unbindEvents: ->
        this.$el.off('.delegateEvents' + this.cid) if this.el
        return this;

    # A finer-grained `unbind` for removing a single delegated event.
    # `selector` and `listener` are both optional.
    unbind: (eventName, selector, listener)->
        this.$el.off(eventName + '.delegateEvents' + this.cid, selector, listener)


    _applyBindingsForKey: (name)->
        return unless this.el
        for item, fns of this._parsedBindings.getGrouped(name)
            for fn in fns
                fn(this.el, _.getPath(this, item), _.last(item.split('.')))

    _initializeBindings: ->
        return unless this.bindings
        this.on('all', (eventName)->
            if eventName.slice(0, 7) == 'change:'
                this._applyBindingsForKey(eventName.split(':')[1]);
        ,this);

    # ## _initializeSubviews
    # this is called at setup and grabs declared subviews
    _initializeSubviews: ->
        return unless this.subviews
        for name, definition of this.subviews
            this._parseSubview(definition, name)

    # ## _subviewClass
    # helper to detect the class for a given subviev
    _subviewClass: (subview)->
        klass = if subview.component
            Lanes.getPath(subview.component, Lanes.Components)
        else if subview.view
            if _.isString(subview.view)
                Lanes.getPath(subview.view, @namespace+".Views")
            else
                subview.view
        Lanes.warn( "Unable to obtain view for %o", subview) if ! klass
        klass

    # ## _parseSubview
    # helper for parsing out the subview declaration and registering
    # the `waitFor` if need be.
    _parseSubview: (subview, name)->
        self = this;
        opts = {
            selector: subview.container || "[data-hook='#{subview.hook||name}']"
            waitFor: subview.waitFor || '',
            prepareView: subview.prepareView || (el,options)->
                klass = self._subviewClass(subview)
                if subview.collection
                    new Lanes.Vendor.Ampersand.CollectionView({
                        el: el, parent: self, viewOptions: options, view: klass,
                        collection: _.getPath(this,subview.collection)
                    })
                else
                    new klass(_.extend(options,{ el: el, parent: self }))

        }

        action = ->
            return if (!this.el || !(el = this.query(opts.selector)))
            if (!opts.waitFor || _.getPath(this, opts.waitFor))
                options = this.subviewOptions(name,subview)
                options.subviewId = name
                subview = this[name] = opts.prepareView.call(this, el, options);
                subview.render();
                this.off('change', action);

        # we listen for main `change` items
        this.on('change', action, this);

    # ## subviewOptions
    # Options to initailize a subview with when it's created
    # Subviews will always be passed the parent (this) and the el.
    # Additional options can be given by specifying "options" on the definition
    # The options can be a method name to call or an object
    # This method can also be overridden to specify the same options to all subviews
    subviewOptions: (name,definition)->
        this.resultsFor(definition.options, name, definition) || {}

    # ## query
    # Get an single element based on CSS selector scoped to this.el
    # if you pass an empty string it return `this.el`.
    # If you pass an element we just return it back.
    # This lets us use `get` to handle cases where users
    # can pass a selector or an already selected element.
    query: (selector)->
        return this el unless selector
        if typeof selector == 'string'
            return this.el if this.$el.is(selector)
            return this.el.querySelector(selector) || undefined;
        return selector;

    # When
    _onModelChange: ->
        for name, definition of this.subviews
            continue unless ( view = this[name] )
            view.model = Lanes.getPath(definition.model, this) if definition.model
            view.collection = Lanes.getPath(definition.collection, this) if definition.collection
        old_model = this.previous(@keypath)
        return if old_model == @model
        this._unBindModel( old_model ) if old_model
        this._bindModel( @model ) if @model

    _bindModel: (model)->
        for event, fn of @modelEvents
            this.listenTo(model, event, fn, this)

    _unBindModel: (model)->
        for event, fn of @modelEvents
            this.stopListening(model,event,fn, this)

    initializeKeyBindings: Lanes.emptyFn

    initializeFormBindings: ->
        @_form_bindings = {}
        for data, selector of @form_bindings
            @_form_bindings[data] = new Lanes.Views.FormBindings(this, data, selector)

    setFieldsFromBindings: ->
        binding.setAllFields() for name, binding of @_form_bindings

    viewpath: ''

    detach: ->
        this.el.parentNode.removeChild(this.el) if this.el.parentNode


    renderAllSubviews: ->
        for name, options of this.subviews
            selector = options.container || '[data-hook="' + options.hook + '"]'
            this.renderSubview(this[name], selector) unless options.collection

    $: (selector)->
        this.$el.find(selector)


    belongsToScreen: ->
        view = this
        while view and ! ( view instanceof Lanes.Views.Screen )
            view = view.parent
        view

    @extended: (klass)->
        # perhaps we should merge 'events','bindings'?


    Lanes.lib.ModuleSupport.includeInto(@)
    @include Lanes.lib.defer
    @include Lanes.lib.debounce
    @include Lanes.lib.results



Lanes.Views.Base = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.State, ViewBase )

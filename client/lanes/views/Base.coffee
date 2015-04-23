amp = Lanes.Vendor.Ampersand
delegateEventSplitter = /^(\S+)\s*(.*)$/
class ViewBase

    extendedProperties: ['ui','subviews']

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

        hasModels:
            deps: ["model"], fn: -> !!@model

        viewport:
            deps: ['parent'], fn:->
                this.root_view?.viewport


    constructor: (options={})->

        this.cid = _.uniqueId('view');
        options || (options = {});
        parent = options.parent;
        delete options.parent;

        this._substituteEventUI()

        Lanes.Vendor.Ampersand.State.call(this, options, {init: false, parent: parent})

        this.on('change:$el',   this._onElementChange, this)
        this.on('change:model', this._onModelChange, this)
        this.on('change:collection', this._onCollectionChange, this)
        this._onModelChange()      if @model
        this._onCollectionChange() if @collection
        this._parsedBindings = Lanes.Vendor.Ampersand.Bindings(this.bindings, this)
        this._initializeBindings();
        if options.el && !this.autoRender
            this._onElementChange();

        this._initializeSubviews();

        this.render() if this.autoRender && this.template

        if !this.pubSub? # if it's unset, not true/false; default to parent or true
            this.pubSub = if this.parent?.pubSub? then this.parent.pubSub else true

        if @formBindings || options.formBindings || @parent?.formBindings
            @formBindings = new Lanes.Views.FormBindings(this, @formBindings||options.formBindings)

        if @keyBindings
            Lanes.Views.Keys.add(this, @keyBindings, @keyScope)

        if @pubSub
            this._pubSub = new Lanes.Views.PubSub(this)

        # all done, call initialize ourselves since we told state not to via 'init:false'
        this.initialize.apply(this, arguments);

    _normalizeUIString: (uiString, ui)->
        uiString.replace(/@ui\.[a-zA-Z_$0-9]*/g, (r)->
            return ui[r.slice(4)]
        )

    _substituteEventUI: ->
        return unless @ui
        if @domEvents
            for selector in _.keys(@domEvents)
                replaced_selector = this._normalizeUIString(selector,@ui)
                if replaced_selector != selector
                    @domEvents[replaced_selector] = @domEvents[selector]
                    delete @domEvents[selector]
        # TODO - also apply ui to binding keys


    # Initialize is an empty function by default. Override it with your own
    # initialization logic.
    initialize: Lanes.emptyFn

    # **render** is the core function that your view can override, its job is
    # to populate its element (`this.el`), with the appropriate HTML.
    render: ->
        Lanes.Views.RenderContext.push( this, @model )
        this.renderContextFree()
        Lanes.Views.RenderContext.pop()
        this

    renderContextFree: ->
        this.replaceEl( this.renderTemplateMethod() );
        this

    # ## listenToAndRun
    # Shortcut for registering a listener for a model
    # and also triggering it right away.
    listenToAndRun: (object, events, handler)->
        bound = _.bind(handler, this)
        this.listenTo(object, events, bound)
        bound();

    # Replaces the current root element with the contents of template
    replaceEl: (template)->
        newDom = Lanes.Vendor.domify(template)
        parent = this.el && this.el.parentNode;
        parent.replaceChild(newDom, this.el) if parent
        if newDom.nodeName == '#document-fragment'
            throw new Error("View #{Lanes.u.path(this.FILE)} can only have one root element.")
        if newDom.nodeName == '#text'
            throw new Error("View #{Lanes.u.path(this.FILE)} must have a root element.")
        this.el = newDom;
        this.onRender?()
        return this;

    # Renders the results of calling method "name"
    # to a string and returns it.
    #
    # The template can either be a string property or a function that returns a string.
    renderTemplateMethod:(name="template",data)->
        template = if this[name]
            _.result(this, name)
        else
            data ||= _.result(this,"#{name}Data")
            template_name = _.result(this, "#{name}Name")
            path = this.resultsFor('templatePrefix', template_name) + '/' + template_name
            Lanes.Templates.render(this, path, data)
        throw new Error("#{Lanes.u.path(this.FILE)} failed to render #{path || name}") unless template
        template

    templateName: -> _.dasherize(_.last(this.FILE.path))

    templatePrefix: (template)->
        if template == "empty-span"
            "lanes/views"
        else
            Lanes.u.dirname(this.FILE)

    templateData: ->
        { model: @model?.toJSON?(), collection: @collection?.toJSON?() }

    FILE: FILE

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
        this._unbindFromObject(@model, @modelEvents) if @model and @modelEvents
        this._unbindFromObject(@collection, @collectionEvents) if @collection and @collectionEvents

        Lanes.Views.Keys.remove(this, @keyBindings, @keyScope) if @keyBindings
        this.trigger('remove', this);
        return this;

    # Change the view's element (`this.el` property), including event re-delegation.
    _onElementChange: (element, delegate) ->
        if changes = this.changedAttributes()
            Lanes.$(changes['el']).off('.delegateEvents' + this.cid) if changes['el']
        this.bindDomEvents()
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
            this.ui[key] = this.$el.filter(selector).add(this.$el.find(selector))


    # Sets callbacks, where `this.domEvents` is a hash of
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
    bindDomEvents: (events)->
        return this if (!(events || (events = _.result(this, 'domEvents'))))
        this.unbindDomEvents();
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
    unbindDomEvents: ->
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
            Lanes.u.findObject(subview.component, 'Components', this.FILE)
        else if subview.view
            if _.isString(subview.view)
                this.findSubView(subview.view)
            else
                subview.view
        Lanes.warn( "Unable to obtain view for %o", subview) if ! klass
        klass

    # ## findSubView
    # searches for the named subview in the appropriate location
    # normal view will search the Views namespace, screens under the screen
    findSubView: (name)->
        Lanes.u.findRelative(name, this.FILE) ||
            @FILE.namespace['Views']?[name] ||
            Lanes.u.getPath(name)

    # ## _parseSubview
    # helper for parsing out the subview declaration and registering
    # the `waitFor` if need be.
    _parseSubview: (subview, name)->
        self = this;
        opts = {
            selector: subview.container || "[data-hook='#{subview.hook||name}']"
            waitFor: subview.waitFor || subview.model || subview.collection || ''
            prepareView: subview.prepareView || (el,options)->
                klass = self._subviewClass(subview)
                if subview.collection
                    new Lanes.Vendor.Ampersand.CollectionView({
                        el: el, parent: self, viewOptions: options, view: klass,
                        collection: _.getPath(this, subview.collection)
                    })
                else
                    options = _.extend(options,{ el: el, parent: self })
                    for attr in ['model','data']
                        if subview[attr]
                            options[attr] = _.getPath(this, subview[attr])
                    new klass(options)

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

    # Called when a different model is set
    _onModelChange: ->
        for name, definition of this.subviews
            continue unless ( view = this[name] )
            view.model = Lanes.u.getPath(definition.model, this) if definition.model
            view.collection = Lanes.u.getPath(definition.collection, this) if definition.collection
        prev = this.previous('model')
        return if prev == @model
        this._unbindFromObject(prev, @modelEvents) if prev
        this._bindToObject(@model, @modelEvents) if @model
        this.onModelChange?(prev)
        true

    _onCollectionChange: ->
        prev = this.previous('collection')
        return if prev == @collection
        this._unbindFromObject(prev, @collectionEvents) if prev
        this._bindToObject(@collection, @collectionEvents)

    _bindToObject: (state_object,events)->
        for event, fn of events
            fn = this[fn] unless _.isFunction(fn)
            this.listenTo(state_object, event, fn, this)

    _unbindFromObject: (state_object,events)->
        for event, fn of events
            fn = this[fn] unless _.isFunction(fn)
            this.stopListening(state_object, event, fn, this)

    initializeKeyBindings: Lanes.emptyFn


    setFieldsFromBindings: ->
        binding.setAllFields() for name, binding of @_form_bindings

    viewpath: ''

    detach: ->
        this.el.parentNode.removeChild(this.el) if this.el.parentNode

    $: (selector)->
        this.$el.find(selector)


    parentScreen: ->
        view = this
        while view and ! ( view instanceof Lanes.Views.Screen )
            view = view.parent
        view

    @extended: (klass)->
        if klass::events && !klass::domEvents
            klass::domEvents == klass::events
            delete klass::events
        # perhaps we should merge 'events','bindings'?


    Lanes.lib.ModuleSupport.includeInto(@)
    @include Lanes.lib.defer
    @include Lanes.lib.debounce
    @include Lanes.lib.results


Lanes.Views.Base = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.State, ViewBase )

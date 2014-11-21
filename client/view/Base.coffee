class ViewBase

    model_events: {}

    extended_properties: [
        'subviews', 'events', 'model_events'
    ]

    derived:
        '$el':
            deps: ['el'], fn: -> this.$()

        root_view:
            deps: ['parent'], fn: ->
                view = this
                while view.parent
                    view = view.parent
                view

    session:
        ui:     'state'
        parent: 'object'
        pubSub: 'boolean'

    template: (context)->
        context.renderTemplateMethod('template')

    constructor: (options={})->
        if !options.ui && options.parent
            view = options.parent
            while view.parent
                view = view.parent
            options.ui = view.ui

        Lanes.Vendor.Ampersand.View.apply(this, arguments)
        if !this.pubSub? # if it's unset, not true/false; default to parent or true
            this.pubSub = if this.parent?.pubSub? then this.parent.pubSub else true
        this.on('change:parent', this._onParentSet)
        this.on('change:model', this._onModelChange)
        this.subViewId = options.subViewId;
        this.initializeFormBindings() if @form_bindings

        if @keyBindings
            Lanes.View.Keys.add(this, @keyBindings, @keyScope)

        if @pubSub
            this._pubSub = new Lanes.View.PubSub(this)

    _onParentSet: ->
        if this.root_view.ui
            this.ui = this.root_view.ui

    unBindModel: (model)->
        for event, fn of @model_events
            model.off(event, this[fn], this )

    bindModel: (model)->
        for event, fn of @model_events
            model.on(event, this[fn], this )

    remove: ->
        this.unBindModel( @model ) if @model
        Lanes.View.Keys.remove(this, @key_bindings, @key_scope) if @key_bindings
        super

    initializeKeyBindings: ->



    initializeFormBindings: ->
        @_form_bindings = {}
        for data, selector of @form_bindings
            @_form_bindings[data] = new Lanes.View.FormBindings(this, data, selector)

    setFieldsFromBindings: ->
        binding.setAllFields() for name, binding of @_form_bindings

    fireEvent: (name, args)->
        evt = document.createEvent('CustomEvent')
        evt.initCustomEvent(name, true, true, args )
        this.el.dispatchEvent(evt)

    prepareSubview: (el, options, identifier)->
        options.view = this._subviewClass(options) unless _.isFunction(options.view)
        args = { parent: this, el: el, subViewId: identifier }
        view_arguments = if options.options
            @resultsFor(options.options, identifier, options)
        else
            {}
        for access in ['model','data']
            args[access] = Lanes.getPath(options[access], this) if options[access]
        if options.collection
            args.view = options.view
            args.viewOptions = view_arguments
            args.collection  = Lanes.getPath(options.collection, this)
            new Lanes.Vendor.Ampersand.CollectionView(args)
        else
            new options.view( _.extend(args,view_arguments) )

    viewpath: ''

    detach: ->
        this.el.parentNode.removeChild(this.el) if this.el.parentNode

    renderTemplate:(name,data={})->
        template = Lanes.Templates.find(name, @namespace)
        if template
            template(data)
        else
            Lanes.fatal( "Template #{name} doesn't exist!" )

    renderTemplateMethod: (method)->
        return '<span></span>' unless name = _.result(this, "#{method}Name")
        this.renderTemplate(name, _.result(this, "#{method}Data") || @model)

    subViewDefinition: ->
        if ( definition = this.parent?.subviews?[ @subViewId ] )
            definition
        else
            null

    renderAllSubviews: ->
        for name, options of this.subviews
            selector = options.container || '[data-hook="' + options.hook + '"]'
            this.renderSubview(this[name], selector) unless options.collection

    withRenderContext: (fn)->
        Lanes.View.RenderContext.push( @subViewId, @model )
        try
            returned = fn.apply(this,arguments)
        catch e
            Lanes.warn e
        finally
            Lanes.View.RenderContext.pop()
        returned

    renderContextFree: ->
        previousClass = this.el?.className
        Lanes.View.Base.__super__.render.apply(this, arguments)
        if previousClass
            this.$el.addClass( previousClass )
        this.onRender?()
        this

    render: (options={})->
        this.withRenderContext( this.renderContextFree )

    $: (selector)->
        if selector then Lanes.$(selector,this.el) else Lanes.$(this.el)

    _onModelChange: (model)->
        for name, definition of this.subviews
            continue unless ( view = this[name] )
            view.model = Lanes.getPath(definition.model, this) if definition.model
            view.collection = Lanes.getPath(definition.collection, this) if definition.collection
        old_model = this.previous(@keypath)
        return if old_model == @model
        this.unBindModel( old_model ) if old_model
        this.bindModel( @model ) if @model

    belongsToScreen: ->
        view = this
        while view and ! ( view instanceof Lanes.View.Screen )
            view = view.parent
        view

    _subviewClass: (subview)->
        klass = if subview.component
            Lanes.getPath("Lanes.Component.#{subview.component}")
        else if subview.view
            if _.isString(subview.view)
                Lanes.getPath(subview.view, "Lanes.View")# || Lanes.getPath("Lanes.View.#{subview.view}")
            else
                subview.view
        Lanes.warn( "Unable to obtain view for %o", subview) if ! klass
        klass

    bindingWriteDefinition: (keypath, options)->
        switch options.type
            when 'booleanAttribute'
                {
                    selector: "change #{options.selector}",
                    handler: (ev)->
                        [model, field] = Lanes.getModelPath(this,keypath)
                        model.set(field,ev.target.checked)
                }
            else
                {}

    cacheElements: (config)->
        super
        this

    cacheJqElements: (config)->
        this.cacheElements(config)
        for key, _ of config
            this[key] = Lanes.$(this[key])
        this

    @configureSubview: (name, subview)->
        fn = if subview.prepareView
            subview.prepareView
        else
            _.partial(this.prototype.prepareSubview, _, subview, name)
        subview.hook=name if !subview.hook && !subview.container
        subview.waitFor=(subview.model || subview.collection ) if ! subview.waitFor
        subview.prepareView = (el)->
            this.subViewIntances ||= {}
            this.subViewIntances[name]=fn.call(this,el)

    @extended: (klass)->
        if views = klass.prototype.subviews
            @configureSubview(name, definition) for name, definition of views
        setupWritableBindings(klass.prototype) if klass.prototype.bindings

    Lanes.lib.ModuleSupport.includeInto(@)
    @include Lanes.lib.defer
    @include Lanes.lib.debounce
    @include Lanes.lib.results



setupWritableBindings=(klass)->
    klass.events ||= {}
    for keypath, options of klass.bindings
        continue unless options.write
        writeFn = ( klass.bindingWriteDefinition || ViewBase.prototype.bindingWriteDefinition )
        definition = writeFn.call(klass, keypath, options)
        klass.events[ definition.selector ] = definition.handler

Lanes.View.Base = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.View, ViewBase )

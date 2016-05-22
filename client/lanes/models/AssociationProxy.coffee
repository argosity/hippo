rememberEvents = (obj, ev, rest) ->
    obj[ev] ||= []
    obj[ev].push rest


relayEvents = (obj, model, meth) ->
    for ev, args of obj or []
        model[meth](ev, arg...) for arg in args

ProxyMethods = {

    replaceProxy: (name, model) ->
        @_association_cache[name] = model

    replaceWithModel: (model, options, whenReadyMethod) ->
        model = new @_proxied_model(model) unless Lanes.u.isModel(model)
        if @_proxied_parent
            if @_proxied_parent.isProxy
                @_proxied_parent.replaceProxy(options.association_name, model)
            else
                @_proxied_parent.replace( @_proxied_options.parent, options.association_name, model )
        relayEvents(@_proxied_events, model, 'on')
        relayEvents(@_proxied_once_events, model, 'once')

        whenReadyMethod?()

        if @_proxied_events?['proxyreplace']
            for ev, args of @_proxied_events['proxyreplace'] or []
                args[0].call(args[1], model)
            delete @_proxied_events['proxyreplace']

        model

    _replaceAndCall: (options, fn) ->
        model = new @_proxied_model()
        retVal = undefined
        @replaceWithModel(model, options, ->
            retVal = fn.call(model, fn)
        )
        retVal


    serialize: (options) ->
        if @_association_cache
            data = {}
            for name, model of @_association_cache
                data[name] = model.dataForSave(options)
            data
        else
            return null
    dataForSave: (options = {}) -> @serialize(options)
    isPersistent: -> false
    api_path:     -> @_proxied_model::api_path()
    getId:        -> @_proxied_options.parent[@_proxied_config.association_pk]
    isNew:        -> _.isBlank(@getId())
    clear:        -> null
    invalidMessageFor: (name) ->
        if @_proxied_model::_definition[name]?.required
            "Cannot be empty"
        else
            ''

    on: (ev, rest...) ->
        rememberEvents( @_proxied_events ||= {}, ev, rest )

    once: (ev, rest...) ->
        rememberEvents( @_proxied_once_events ||= {}, ev, rest )

    off: (ev, rest...) ->
        delete @_proxied_events[ev]

}

Lanes.Models.AssocationProxy = {
    NullGetter: ->
        return null

    fowardingFuncDefinition: (name, options) ->
        -> args = arguments; @_replaceAndCall options, -> @[name](args...)

    fieldDefinition: (name, definition, options) ->
        enumerable: true
        get: @NullGetter
        set: (value) ->
            @_replaceAndCall options, -> @[name] = value

    derivedDefinition: (name, definition, options) ->
        enumerable: true
        get: @NullGetter
        set: ->
            throw new TypeError('"' + name + '" is a derived property, it can\'t be set directly.')


    associationDefinition: (name, definition, options) ->
        enumerable: true
        set: ->
            throw new TypeError('"' + name + '" is an association property, it can\'t be set directly.')

        get: ->
            @_association_cache ||= Object.create(null)
            @_association_cache[name] ||= (
                klass = @_proxied_model::associations.getClassFor(name)
                Proxy = Lanes.Models.AssocationProxy.construct(klass,
                    association_name: name
                )
                new Proxy(@, @_proxied_model::associations.getOptions(name, @))
            )


    construct: (klass, config) ->
        AssociationProxy = (parent, options) ->
            @_proxied_parent  = parent
            @_proxied_options = options
            @_proxied_config  = config
            undefined


        _.extend(AssociationProxy.prototype, ProxyMethods)

        AssociationProxy.Collection = klass.Collection

        AssociationProxy::_proxied_model = klass

        definedProps = {
            isProxy: { value: true, enumerable: true, writable: false }
            id: { get: -> @getId() }
        }
        if klass::associations?
            definedProps.associations =
                enumerable: true
                get: -> klass::associations
            for name, definition of klass::associations?.definitions
                definedProps[name] = @associationDefinition(name, definition, config)

        if klass::_definition?
            for name, definition of klass::_definition when not definedProps[name]
                definedProps[name] = @fieldDefinition(name, definition, config)

        if klass::_derived?
            for name, definition of klass::_derived when not definedProps[name]
                definedProps[name] = @derivedDefinition(name, definition, config)

        Object.defineProperties(AssociationProxy.prototype, definedProps)

        for name, method of klass.prototype when _.isFunction(method) and not AssociationProxy::[name]
            AssociationProxy::[name] = @fowardingFuncDefinition(name, config)

        AssociationProxy


}

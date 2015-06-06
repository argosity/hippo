Lanes.Extensions = {

    instances: {}

    register: (klass) ->
        instance = new klass
        this.instances[klass.prototype.identifier] = instance
        instance.onRegistered?()

    fireOnInitialized: (viewport) ->
        instance.onInitialized?(viewport) for identifier, instance of @instances

    fireOnAvailable: (viewport) ->
        instance.onAvailable?(viewport) for identifier, instance of @instances

    getViews: ->
        _.Promise.all _.invoke(@instances, 'getView')

    setBootstrapData: (bootstrap_data) ->
        @controlling_id = bootstrap_data.controlling_extension
        for identifier, instance of @instances
            instance.setBootstrapData?(bootstrap_data[identifier])

    makeNamespace: (identifier) ->
        for ns in ['Models', 'Controllers', 'Screens', 'Components']
            Lanes.namespace("#{identifier}.#{ns}.Mixins")

    controlling: ->
        this.get( @controlling_id )

    routes: ->
        _.flatten _.map @instances, (instance, id) ->
            instance.getRoutes?()

    get: (identifier) ->
        this.instances[identifier]
}

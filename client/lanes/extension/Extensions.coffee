Lanes.Extensions = {

    instances: {}

    register: (klass)->
        instance = new klass
        this.instances[klass.prototype.identifier] = instance
        instance.onRegistered?()

    fireOnAvailable: (application)->
        instance.onAvailable?(application) for identifier, instance of @instances

    setBootstrapData: (bootstrap_data)->
        @controlling_id = bootstrap_data.controlling_extension
        for identifier,data of bootstrap_data
            instance = this.instances[identifier]
            instance?.setBootstrapData?(data)

    makeNamespace: (identifier)->
        for ns in ['Models','Views','Controllers','Screens','Components']
            Lanes.namespace("#{identifier}.#{ns}.Mixins")

    controlling: ->
        this.get( @controlling_id )

    get: (identifier)->
        this.instances[identifier]
}

Lanes.Extensions = {

    instances: {}

    register: (klass)->
        instance = new klass
        this.instances[klass.prototype.identifier] = instance
        instance.onRegistered?()

    fireOnAvailable: (application)->
        instance.onAvailable?(application) for identifier, instance of @instances

    setBootstrapModels: (bootstrap_data)->
        for identifier,data of bootstrap_data
            instance?.setBootstrapModels?(data)

    makeNamespace: (identifier)->
        for ns in ['Models','Views','Controllers','Screens']
            Lanes.namespace("#{identifier}.#{ns}")


    get: (identifier)->
        this.instances[identifier]
}

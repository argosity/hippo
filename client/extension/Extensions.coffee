Lanes.Extensions = {

    instances: {}

    register: (klass)->
        instance = new klass
        this.instances[klass.prototype.identifier] = instance
        instance.onRegistered?()

    fireOnAvailable: (application)->
        instance.onAvailable?(application) for identifier, instance of @instances

    setBootstrapData: (bootstrap_data)->
        for identifier,data of bootstrap_data
            instance.setBootstrapData(data) if instance = this.instances[identifier]

    makeNamespace: (identifier)->
        for ns in ['Data','View','Controller','Screen']
            Lanes.namespace("#{identifier}.#{ns}")


}

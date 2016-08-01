class NetworkEventListener

    constructor: (component) -> @component = component

    bindEvents: (events, model) ->
        model.on('error', @onError, @)
            .on('request', @onRequest, @)
            .on('load sync', @)

    unBindEvents: (events, model) ->
        model.off(null, null, @)

    setState: (state, options) ->
        return if options?.silent
        fn = @component.setNetworkActivity or @component.setState
        fn.call(@component, state)

    onError: (modelOrCollection, options) ->
        @setState(
            isRequesting: false
            hasError: modelOrCollection?.errorMessage or true
            errors: modelOrCollection.errors
        )

    onRequest: (modelOrCollection, type, options) ->
        @setState(
            isRequesting: true
            hasError: false
            errors: []
        )

    onSync: (modelOrCollection, res, options = {}) ->
        @setState(isRequesting: false)

getNetworkListener = (component) ->
    return unless _.result(component, 'listenNetworkEvents') is true
    component._networkEventsListener ||= new NetworkEventListener(component)

Lanes.React.Mixins.Data = {

    onModelUnbind: (model, name) ->
        Lanes.Models.PubSub.remove(model)
        getNetworkListener(@)?.unBindEvents(@modelBindings, @[name])

    onModelBind: (model, name) ->
        model = this[name]
        return unless Lanes.u.isModel(model)

        getNetworkListener(@)?.bindEvents(@modelBindings, @[name])

        return if _.result(model, 'registerForPubSub') is false or
            _.result(@, 'registerForPubSub') is false

        if model.isNew()
            model.once "change:#{model.idAttribute}", -> Lanes.Models.PubSub.add(model)
        else
            Lanes.Models.PubSub.add(model)

        this.modelBindings.listenTo(model, 'remote-update', (model, cs) =>
            screen = @context?.screen || @getChildContext?()?.screen
            screen?.onPubSubChangeSet?(model, cs)
        )


}

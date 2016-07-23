class NetworkEventListener

    constructor: (component) -> @component = component

    bindEvents: (events, model) ->
        events.listenTo(model, 'error',     @onError)
            .listenTo(model,   'request',   @onRequest)
            .listenTo(model,   'load sync', @onSync)

    onError: (modelOrCollection, options) ->
        @component.setState(
            isRequesting: false
            hasError: modelOrCollection?.errorMessage or true
            errors: modelOrCollection.errors
        ) unless options?.silent

    onRequest: (modelOrCollection, type, options) ->
        @component.setState(
            isRequesting: true
            hasError: false
            errors: []
        ) unless options?.silent

    onSync: (modelOrCollection, res, options = {}) ->
        @component.setState(isRequesting: false) unless options?.silent

getNetworkListener = (component) ->
    return unless _.result(component, 'listenNetworkEvents') is true
    component._networkEventsListener ||= new NetworkEventListener(component)

Lanes.React.Mixins.Data = {

    onModelUnbind: (model, name) ->
        Lanes.Models.PubSub.remove(model)

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

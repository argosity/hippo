class NetworkEventListener

    constructor: (@component) ->

    bindEvents: (events, model) ->
        events.listenTo(model, 'error',     @onError)
            .listenTo(model,   'request',   @onRequest)
            .listenTo(model,   'load sync', @onSync)

    onError: (modelOrCollection, options) ->
        # Set state only if there's no silent option
        return if options.silent
        @component.setState
            isRequesting: false
            hasError: modelOrCollection?.errorMessage or true
            error: modelOrCollection.errors

    onRequest: (modelOrCollection, type, options) ->
        # Set `state` only if there's no silent option
        unless options.silent
            @setComponentState
                isRequesting: type
                hasError: false
                isInvalid: false

    onSync: (modelOrCollection, res, options = {}) ->
        # Calls `setReactState` only if there's no silent option
        this.setComponentState(isRequesting: false) unless options.silent


Lanes.React.Mixins.Data = {

    getInitialState: ->
        @_networkEventsListener = new NetworkEventListener(this) if @listenNetworkEvents

    onModelUnbind: (model, name) ->
        Lanes.Models.PubSub.remove(model)

    onModelBind: (model, name) ->
        model = this[name]
        return unless Lanes.u.isModel(model)
        @_networkEventsListener?.bindEvents(@modelBindings, @[name])

        return unless _.result(model, 'registerforPubSub') isnt false and
            not (false == @pubsub or false == @pubsub?[name])

        if model.isNew()
            model.once "change:#{model.idAttribute}", -> Lanes.Models.PubSub.add(model)
        else
            Lanes.Models.PubSub.add(model)

        this.modelBindings.listenTo(model, 'remote-update', (model, cs) =>
            screen = @context?.screen || @getChildContext?()?.screen
            screen?.onPubSubChangeSet?(model, cs)
        )


}

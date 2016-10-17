class ModelConfig

    constructor: (@type, model) ->
        @id = model.getId()
        @channel = "#{_.result(model, 'api_path')}/#{@id}"
        @count = 0
        @models = []

    add: (model) ->
        if @count is 0
            Lanes.Models.PubSub.channel?.subscribe(@channel) #, @mbCallBack(@models))
        @count += 1
        config = @modelConfig(model)
        config.count += 1

    modelConfig: (model) ->
        config = _.find(@models, {model: model})
        unless config
            config = {model: model, count: 0}
            @models.push(config)
        config

    remove: (model) ->
        config = _.find(@models, {model: model})
        return unless config
        @count -= 1
        if @count is 0 # all removed, just unsubscribe
            @unsubscribe()
        else
            config.count -= 1
            _.remove(@models, {model: model}) if config.count is 0

    unsubscribe: ->
        Lanes.Models.PubSub.channel?.unsubscribe( @channel )
        delete @type.records[@id]

    onChange: (data) ->
        config.model.addChangeSet(data) for config in @models

class ModelType

    constructor: (attr) ->
        _.extend(@, attr)
        @records = {}

    add: (model) ->
        config = @records[model.id] ||= new ModelConfig(this, model)
        config.add(model)

    remove: (model) ->
        @records[model.id]?.remove(model)

    onChange: (id, data) ->
        @records[id].onChange(data)

    unsubscribeAll: ->
        record.unsubscribe() for id, record of @records

class ModelTypesCollection extends Lanes.Models.BasicCollection

    constructor: -> super
    model: ModelType

    forModel: (model) ->
        path = _.result(model, 'api_path')
        models = this.get(path) || this.add(id: path)


CableChannel = {
    connected: ->
        @subscribe 'file-change', ->
            Lanes.lib.HotReload.initiate(changes)

    subscribe: (channel) ->
        Lanes.log.info "[pubsub] subscribe to: #{channel}"

        @perform("on", {channel})

    unsubscribe: (channel) ->
        Lanes.log.info "[pubsub] unsubscribe from: #{channel}"
        @perform("off", {channel})

    received: (data) ->
        [channel, model, id] = data.channel.match(/(.*)\/(\d+)/)
        Lanes.log.info "[pubsub] change recvd for: #{channel}"

        Lanes.Models.PubSub.onChange(
            model, id, _.omit(data, 'channel')
        )

}

Lanes.Models.PubSub = {

    types: new ModelTypesCollection

    add: (model) ->
        return unless model.isPersistent?()
        @types.forModel(model).add(model)

    remove: (model) ->
        return unless model && model.isPersistent?()
        @types.forModel(model).remove(model)

    instanceFor: ( model_klass, id ) ->
        path = _.result(model_klass.prototype, 'api_path')
        @types.get(path)?.records[id]?.models[0]?.model

    clear: ->
        @types = new ModelTypesCollection

    initialize: ->
        Lanes.current_user.on 'change:isLoggedIn', _.bind(@onLoginChange, @)
        @onLoginChange() if Lanes.current_user.isLoggedIn

    onChange: (path, id , data) ->
        @types.get(path).onChange(id, data)

    onLoginChange: ->
        if Lanes.current_user.isLoggedIn
            url = window.location.protocol.replace('http', 'ws') +
                "//#{Lanes.config.api_host}#{Lanes.config.api_path}/ws"
            @cable = ActionCable.createConsumer(url)
            @channel = @cable.subscriptions.create "Lanes::API::PubSub", CableChannel
        else
            Lanes.Models.PubSub.types.each (t) -> t.unsubscribeAll()
            delete @channel
            @cable.disconnect()
            delete @cable

}

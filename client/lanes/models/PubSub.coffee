class ModelConfig

    constructor: (@type, model) ->
        @id = model.getId()
        @channel = "#{_.result(model, 'api_path')}/#{@id}"
        @count = 0
        @models = []

    add: (model) ->
        if @count is 0
            Lanes.log.info "[pubsub] subscribe to: #{@channel}"
            Lanes.Models.PubSub.mb.subscribe(@channel, @mbCallBack(@models))
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
        Lanes.log.info "[pubsub] unsubscribe from: #{@channel}"
        Lanes.Models.PubSub.mb?.unsubscribe( @channel )
        delete @type.records[@id]

    mbCallBack: (models) ->
        (changes) ->
            config.model.addChangeSet(changes) for config in models


class ModelType

    constructor: (attr) ->
        _.extend(@, attr)
        @records = {}

    add: (model) ->
        config = @records[model.id] ||= new ModelConfig(this, model)
        config.add(model)

    remove: (model) ->
        @records[model.id]?.remove(model)


class ModelTypesCollection extends Lanes.Models.BasicCollection

    constructor: -> super
    model: ModelType

    forModel: (model) ->
        path = _.result(model, 'api_path')
        models = this.get(path) || this.add(id: path)


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
        @mb ||= MessageBus.noConflict()
        @mb.start()
        @mb.subscribe("/file-change", (changes) ->
            Lanes.lib.HotReload.initiate(changes)
        )
}

class ModelType extends Lanes.Models.State

    constructor: ->
        super
        @records = {}

    session:
        id: 'string'
        records: 'object'

    subscribe: (config) ->
        model = config.models[0]
        channel = "/#{_.result(model, 'api_path')}/#{model.id}"
        Lanes.Vendor.MessageBus.subscribe(channel, (changes) ->
            for model in config.models
                model.addChangeSet(changes)
        )
        channel

    add: (model) ->
        if (config = @records[model.id])
            config.models.push(model) unless _.include(config.models, model)
        else
            config = { models: [model] }
            config.channel = this.subscribe(config)
            @records[model.id] = config

    remove: (model) ->
        if ( config = @records[model.id] )
            _.remove(config.models, (m) -> m == model)
            if _.isEmpty(config.models)
                Lanes.Vendor.MessageBus.unsubscribe( config.channel )
                delete @records[model.id]


class ModelTypesCollection extends Lanes.Models.BasicCollection

    constructor: -> super
    model: ModelType

    forModel: (model) ->
        path = _.result(model, 'api_path')
        models = this.get(path) || this.add(id: path)


Lanes.Models.PubSub = {

    types: new ModelTypesCollection

    # forModel: (model) ->

    add: (model) ->
        return unless model.isPersistent?()
        @types.forModel(model).add(model)

    remove: (model) ->
        return unless model && model.isPersistent?()
        @types.forModel(model).remove(model)

    instanceFor: ( model_klass, id ) ->
        path = _.result(model_klass.prototype, 'api_path')
        @types.get(path)?.records[id]?.models[0]

    clear: ->
        @types = new ModelTypesCollection

    initialize: ->
        Lanes.Vendor.MessageBus.start()
        Lanes.Vendor.MessageBus.subscribe("/file-change", (changes) ->
            Lanes.lib.HotReload.initiate(changes)
        )
}

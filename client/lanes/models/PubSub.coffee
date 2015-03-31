class ModelType extends Lanes.Models.State

    constructor: ->
        super
        @records = {}

    session:
        id: 'string'
        records: 'object'

    subscribe: (model)->
        channel = "/#{_.result(model,'api_path')}/#{model.id}"
        Lanes.Vendor.MessageBus.subscribe(channel,(changes)->
            model.addChangeSet(changes)
        )
        channel

    add: (model)->
        if (config = @records[model.id])
            config.model = model
        else
            @records[model.id] = { model: model, channel: this.subscribe(model) }

    remove: (model)->
        if ( config = @records[model.id] )
            Lanes.Vendor.MessageBus.unsubscribe( config.channel )
        delete @records[model.id]


class ModelTypesCollection extends Lanes.Models.BasicCollection

    constructor: -> super
    model: ModelType

    forModel: (model)->
        path = _.result(model,'api_path')
        models = this.get(path) || this.add(id: path)


Lanes.Models.PubSub = {

    types: new ModelTypesCollection

    forModel: (model)->

    add: (model)->
        return unless model.isPersistent?()
        @types.forModel(model).add(model)

    remove: (model)->
        return unless model && model.isPersistent?()
        @types.forModel(model).remove(model)

    instanceFor: ( model_klass, id )->
        @types.get(_.result(model_klass.prototype,'api_path'))?.records[id]?.model

    clear: ->
        @types = new ModelTypesCollection

    initialize: ->
        Lanes.Vendor.MessageBus.start()
        Lanes.Vendor.MessageBus.callbackInterval = 500

}


class ModelType extends Lanes.Data.State
    constructor: ->
        super
        @records = {}

    session:
        id: 'string'
        records: 'object'

    subscribe: (model)->
        channel = "/#{model.api_path}/#{model.id}"
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



class ModelTypesCollection extends Lanes.Data.BasicCollection
    constructor: -> super
    model: ModelType

    forModel: (model)->
        models = this.get(model.api_path) || this.add(id: model.api_path)


Lanes.Data.PubSub = {

    types: new ModelTypesCollection

    forModel: (model)->

    add: (model)->
        return unless model.isPersistent()
        @types.forModel(model).add(model)

    remove: (model)->
        return unless model && model.isPersistent()
        @types.forModel(model).remove(model)

    instanceFor: ( model_klass, id )->
        @types.get(model_klass.prototype.api_path)?.records[id]?.model

    clear: ->
        @types = new ModelTypesCollection

    initialize: ->
        Lanes.Vendor.MessageBus.start()
        Lanes.Vendor.MessageBus.callbackInterval = 500

}

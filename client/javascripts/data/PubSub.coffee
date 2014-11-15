MB = Lanes.Vendor.MessageBus

class ModelType
    constructor: ->
        super
        @records = {}

    session:
        id: 'string'
        records: 'object'

    subscribe: (model)->
        channel = "/#{model.api_path}/#{model.id}"
        MB.subscribe(channel,(changes)->
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
            MB.unsubscribe( config.channel )
        delete @records[model.id]


Lanes.Data.State.extend(ModelType)

class ModelTypesCollection
    constructor: -> super
    model: ModelType

    forModel: (model)->
        models = this.get(model.api_path) || this.add(id: model.api_path)

Lanes.Data.BasicCollection.extend(ModelTypesCollection)



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
        MB.start()
        MB.callbackInterval = 500

}

class Lanes.Models.Query.CollectionResult

    constructor: (@query) ->
        this

    rowAt: (index, options = {}) ->
        model = @collection.at(index)
        for field, i in @query.fields.models when (not options.visibleOnly or field.visible)
            field.format?(model[field.id], model, @query) or model[field.id]

    modelAt: (index) ->
        @collection.at(index).clone()

    saveModelChanges: (model, index) ->
        @collection.at(index).copyFrom(model)

    addBlankRow: ->
        @collection.add({}, at: 0)

    ensureLoaded: ->
        @collection.ensureLoaded()

Object.defineProperties Lanes.Models.Query.CollectionResult.prototype,
    length:
        get: -> @query.src.length
    collection:
        get: -> @query.src

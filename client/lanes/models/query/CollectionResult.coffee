class Lanes.Models.Query.CollectionResult

    constructor: (@query) ->
        this

    rowAt: (index, options = {}) ->
        model = @collection.at(index)
        for field, i in @query.fields.models when (not options.visibleOnly or field.visible)
            if field.format then field.format(model[field.id], model, @query) else model[field.id]

    modelAt: (index) ->
        @collection.at(index)

    saveModelChanges: (model, index) ->
        @collection.at(index).copyFrom(model)

    addBlankRow: (index) ->
        @collection.add({}, at: index)

    removeRow: (index = 0) ->
        @collection.remove(
            @collection.at(index)
        )

    ensureLoaded: ->
        @collection.ensureLoaded()

Object.defineProperties Lanes.Models.Query.CollectionResult.prototype,
    length:
        get: -> @query.src.length
    collection:
        get: -> @query.src

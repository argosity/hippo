class Lanes.Models.Query.CollectionResult extends Lanes.Models.Query.Result

    constructor: (@query) ->
        @collection.on('add remove reset', =>
            @query.trigger('change', @query)
        )
        this

    rowAt: (index, options = {}) ->
        model = @collection.at(index)
        for field, i in @query.fields.models
            model[field.id]

    allRows: (options) ->
        rows = (@rowAt(i, options) for i in [0...@length])
        _.Promise.resolve(rows)

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

    reload: ->
        @collection.reload().then(@)

    ensureLoaded: ->
        @collection.ensureLoaded().then(@)


    rowRepresentation: (rowNum) ->
        @modelAt(rowNum)

    valueForField: (rowNum, field) ->
        @modelAt(rowNum)[field.id]

    _updateSort: ->
        field = @query.sortField
        asc = @query.sortAscending


        @collection.comparator = field.sortBy or (a, b) ->
            a = a[field.id]; b = b[field.id]
            result = if a < b then -1 else if b > a then 1 else 0
            if asc then result else result * -1


    #     @sort =
    #         asc: asc, index: @query.fields.indexOf(field)
    #         visibleIndex: @query.fields.visible.indexOf(field)
    #     @collection.comparator = (a, b) ->
    #         sort = field.comparator(a, b)
    #         if asc then sort else sort * -1
    #     @query.trigger('sort')
    #     @collection.sort()

Object.defineProperties Lanes.Models.Query.CollectionResult.prototype,
    length:
        get: -> @query.src.length
    collection:
        get: -> @query.src

class Lanes.Models.Query.CollectionResult extends Lanes.Models.Query.Result

    constructor: (@query) ->
        @collection.on('add remove reset', =>
            @query.trigger('change', @query)
        )
        @collection.on('sort', =>
            @query.changeCount += 1
        )

        this

    rowAt: (index, options = {}) ->
        model = @collection.at(index)
        for field, i in @query.fields.models
            model[field.id]

    allRows: (options) ->
        rows = (@rowAt(i, options) for i in [0...@length])
        _.Promise.resolve(rows)

    modelAt: (index, options = {}) ->
        model = @collection.at(index)
        if options.clone then model.clone() else model

    saveModelChanges: (model, index) ->
        old = @collection.at(index)

        @collection.remove(old)
        @collection.add(model, at:index)
        @query.changeCount++

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

    reset: Lanes.emptyFn

    rowRepresentation: (rowNum) ->
        @modelAt(rowNum)

    valueForField: (rowNum, field) ->
        @collection.at(rowNum)[field.id]

    fieldToSortValue:
        any:    (v) -> v
        bigdec: (v) -> parseFloat(v)

    _updateSort: ->
        field = @query.sortField
        asc = @query.sortAscending
        f2v = @fieldToSortValue[field.type] || @fieldToSortValue.any
        @collection.comparator = field.sortBy or (a, b) ->
            a = f2v(a[field.id]); b = f2v(b[field.id])
            result = if a < b then -1 else if a > b then 1 else 0
            if asc then result else result * -1
        @collection.sort()

Object.defineProperties Lanes.Models.Query.CollectionResult.prototype,
    length:
        get: -> @query.src.length
    collection:
        get: -> @query.src

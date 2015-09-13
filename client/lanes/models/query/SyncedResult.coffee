class Page

    constructor: (@pageNum, @result, options = {}) ->
        query = {}
        @rows = []
        @result.query.clauses.each (clause) ->
            _.extend( query, clause.toParam() ) if clause.isValid

        options = {
            format: 'array', total_count: 't'
            start: @pageNum * @result.pageSize, limit: @result.pageSize,
            query: query, url: @result.query.src::urlRoot(),
            fields: _.pluck( @result.query.fields.where(query: true), 'id')
        }

        _.extend(options, Lanes.u.invokeOrReturn(@result.query.syncOptions))

        @pendingLoad = Lanes.Models.Sync.perform('GET', options).then (resp) =>
            @result.total = resp.total
            @rows  = resp.data
            delete @pending
            @result.onPageLoad(@)

    _normalizedIndex: (index) ->
        index = index % @result.pageSize

    # N.B. for convenience the index for the methods below is the absolute index for all results
    # not the index just for this page.  It's converted and the appropriate row returned
    _rowAt: (index) ->
        row = @rows[ @_normalizedIndex(index) ] || []

    _rowToModel: (row) ->
        attrs = {}
        for field, i in @result.query.fields.models
            attrs[field.id] = row[i]
        new @result.query.src(attrs)

    rowAt: (index) ->
        row = @_rowAt(index)
        @result.query.fields.map (field, i) =>
            field.format?(row[i], row, @result.query) or row[i]

    modelAt: (index) ->
        row = @_rowAt(index)
        @modelCache ||= {}
        id = @idForRow(row)
        if _.isBlank(id)
            @_rowToModel(row)
        else
            @modelCache[id] ||= @_rowToModel(row)

    saveModelChanges: (model, index) ->
        row = @_rowAt(index)
        cachedModel = @modelCache[ @idForRow(row)] if @modelCache
        if cachedModel
            cachedModel.copyFrom(model)
        for field, i in @result.query.fields.models
            row[i] = model[field.id]

    idForRow: (row) ->
        row[@result.query.idIndex]

    addBlankRow: (index) ->
        model = new @result.query.model
        row = []
        for field, i in @result.query.fields.models
            row[i] = model[field.id]
        @rows.splice(@_normalizedIndex(index), 0, row)

    removeRow: (index = 0) ->
        @rows.splice(@_normalizedIndex(index), 1)

class Lanes.Models.Query.SyncedResult

    constructor: (q, options = {}) ->
        @query = q
        @pageSize = options.pageSize || 20
        @pages = {}

    reset: ->
        @pages = {}

    pageForIndex: (index) ->
        pageNum = Math.floor(index / @pageSize)
        @pages[pageNum] ||= new Page(pageNum, this)

    visibleIndexes: ->
        @_visibleIndexes ||= (
            _.compact( @query.fields.map( (f, i) ->
                if f.visible then i else null
            ))
        )

    rowAt: (index, options = {}) ->
        row = @pageForIndex(index).rowAt(index)
        if options.visibleOnly
            row[fieldIndex] for fieldIndex in @visibleIndexes()
        else
            row

    allRows: (options) ->
        rows = (@rowAt(i, options) for i in [0...@length])
        _.Promise.resolve(rows)

    modelAt: (index) ->
        @pageForIndex(index).modelAt(index)

    saveModelChanges: (model, index) ->
        @pageForIndex(index).saveModelChanges(model, index)

    removeRow: (index = 0) ->
        @total -= 1
        @pageForIndex(index).removeRow(index)

    addBlankRow: (index = 0) ->
        @total += 1
        @pageForIndex(index).addBlankRow(index)

    ensureLoaded: (options) ->
        @pageForIndex(options.page || 0).pendingLoad or _.Promise.resolve(@)

    onPageLoad: (page) ->
        @query.trigger('load', @query)
        @


Object.defineProperty Lanes.Models.Query.SyncedResult.prototype, 'length',
    get: -> @total || 0

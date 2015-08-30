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

    # N.B. for convenience the index for the methods below is the absolute index for all results
    # not the index just for this page.  It's converted and the appropriate row returned
    _rowAt: (index) ->
        index = index % @result.pageSize
        row = @rows[index] || []

    rowAt: (index) ->
        row = @_rowAt(index)
        @result.query.fields.map (field, i) ->
            field.format?(row[i], row, @result.query) or row[i]

    modelAt: (index) ->
        row = @_rowAt(index)
        @modelCache ||= {}
        @modelCache[ @idForRow(row)] ||= (
            attrs = {}
            for field, i in @result.query.fields.models
                attrs[field.id] = row[i]
            new @result.query.src(attrs)
        )

    saveModelChanges: (model, index) ->
        row = @_rowAt(index)
        cachedModel = @modelCache[ @idForRow(row)] if @modelCache
        if cachedModel
            cachedModel.copyFrom(model)
        for field, i in @result.query.fields.models
            row[i] = model[field.id]

    idForRow: (row) ->
        row[@result.query.idIndex]



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

    rowAt: (index, options = {}) ->
        row = @pageForIndex(index).rowAt(index)
        if options.visibleOnly
            @visibleIndexes ||= _.compact @query.fields.map (f, i) -> if f.visible then i else null
            row[fieldIndex] for fieldIndex in @visibleIndexes
        else
            row

    modelAt: (index) ->
        @pageForIndex(index).modelAt(index)

    saveModelChanges: (model, index) ->
        @pageForIndex(index).saveModelChanges(model, index)

    addBlankRow: ->
        model = new @query.model
        row = []
        for field, i in @query.fields.models
            row[i] = model[field.id]
        @rows.unshift row

    ensureLoaded: ->
        if _.isEmpty(@pages)
            @pageForIndex(0).pendingLoad
        else
            _.Promise.resolve(@)

    onPageLoad: (page) ->
        @query.trigger('load', @query)


Object.defineProperty Lanes.Models.Query.SyncedResult.prototype, 'length',
    get: -> @total || 0

class Page

    constructor: (@pageNum, @result, options = {}) ->
        query = {}
        @rows = []
        @result.query.clauses.each (clause) ->
            _.extend( query, clause.toParam() ) if clause.isValid
        options = {
            format: 'array', total_count: 't'
            start: @pageNum * @result.pageSize, limit: @result.pageSize,
            query: query, url: @result.query.url,
            fields: @result.query.fields.pluck('id')
        }

        Lanes.Models.Sync.perform('GET', options).then (resp) =>
            @result.total = resp.total
            @rows  = resp.data
            delete @pending
            @result.onPageLoad(@)

    # N.B. for convenience the index for the methods below is the absolute index for all results
    # not the index just for this page.  It's converted and the appropriate row returned
    rowAt: (index) ->
        index = index % @result.pageSize
        @rows[index] || []

    modelAt: (index) ->
        row = @rowAt(index)
        @modelCache ||= {}
        @modelCache[ @idForRow(row)] ||= (
            attrs = {}
            for field, i in @result.query.fields.models
                attrs[field.id] = row[i]
            new @result.query.modelClass(attrs)
        )

    idForRow: (row) ->
        row[@result.query.idIndex]



class Lanes.Models.QueryResults

    constructor: (q, options = {}) ->
        @cid = _.uniqueId()
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


    saveModelChanges: (model) ->
        page = @pageForIndex
        @_calculateCache() unless @idCache
        row = @idCache[model.id]
        for field, i in @query.fields.models
            row[i] = model[field.id]
        model

    addBlankRow: ->
        model = new @query.modelClass()
        row = []
        for field, i in @query.fields.models
            row[i] = model[field.id]
        @rows.unshift row

    ensureLoaded: ->
        @pageForIndex(0) if _.isEmpty(@pages)
        return null

    onPageLoad: (page) ->
        console.log 'page load'
        @query.trigger('load', @query)


Object.defineProperty Lanes.Models.QueryResults.prototype, 'length',
    get: -> @total || 0

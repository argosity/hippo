##= require_self
##= require ./query/Result
##= require ./query/ArrayResult
##= require ./query/CollectionResult

class Field extends Lanes.Models.Base
    registerForPubSub: false

    constructor: (attributes) ->
        super( _.defaults( attributes, {
            title: _.titleize(_.humanize(attributes.id))
        }))

    session:
        id:         type: 'string'
        title:      type: 'string'
        selected:   type: 'boolean'
        visible:    type: 'boolean', default: true
        query:      type: 'boolean', default: true
        editable:   type: 'boolean', default: true
        sortable:   type: 'boolean', default: true
        format:     type: 'function'
        flex:       type: 'number',  default: 1
        fixedWidth: type: 'number'
        textAlign:  type: 'string', default: 'left'
        sortBy:     type: 'any'
        component:  type: 'function'
        onColumnClick: type: 'function'

    derived:
        default_value: deps: ['id'], fn: ->
            switch @model_field.type
                when 'integer' then 0
                else ''
        model_field:
            deps: ['id'], fn: ->
                this.collection.query.model::_definition[@id]
        type:
            deps: ['model_field'], fn: ->
                type = @model_field?.type || 'string'
                if type == "code" then "string" else type
        fetchIndex:
            fn: ->
                fetchIndex = 0
                for field, index in this.collection.models
                    return fetchIndex if this == field
                    fetchIndex += 1 if field.query

    validValue: (value) ->
        if this.type == 'n'
            ! _.isNaN( parseFloat(value) )
        else
            value


class AvailableFields extends Lanes.Models.Collection

    model: Field

    constructor: (models, options) ->
        @query = options.query
        this.on('change', (changing) ->
            return unless changing.selected
            for model in @models
                model.selected = false unless model == changing
        )
        super
        @visible = @subcollection(where: {visible: true})


class Operator extends Lanes.Models.Base
    registerForPubSub: false

    session:
        id:       'string'
        name:     'string'
        types:    'array'
        field:    'object'
        selected: 'boolean'

    validForField: (field) ->
        _.isEmpty(@types) or _.includes(this.types, field.type)


class Operators extends Lanes.Models.Collection
    model: Operator

    constructor: (models, attrs) ->
        super
        this.add([
            { id: 'like', name: 'Starts With', types: Lanes.Models.Query.LIKE_QUERY_TYPES }
            { id: 'eq',   name: 'Equals' }
            { id: 'lt',   name: 'Less Than', types: Lanes.Models.Query.LESS_THAN_QUERY_TYPES }
            { id: 'gt',   name: 'More Than', types: Lanes.Models.Query.LESS_THAN_QUERY_TYPES }
        ])
        this.on('change', (changing) ->
            return unless changing.selected
            for model in @models
                model.selected = false unless model == changing
        )
        @setField(attrs.parent.query.initialField)

    setField: (field) ->
        @field = field
        @valid = @subcollection(filter: (op) => op.validForField(@field) )
        selected = this.findWhere(selected: true)
        unless selected && selected.validForField(field)
            @valid.at(0)?.selected = true


class Clause extends Lanes.Models.Base
    registerForPubSub: false

    session:
        value     : { type: 'string', default: '' }
        field     : 'state'
        operator  : 'state'

    associations:
        operators : { collection: Operators }
        fields:     { collection: AvailableFields }

    derived:
        description:
            deps: ['field', 'operator']
            fn: -> "#{@field.title} #{@operator?.id}"

        isValid:
            deps: ['field', 'operator', 'value']
            fn: -> this.field.validValue(@value)

        query:
            fn: -> @collection.query

    constructor: (options) ->
        super
        this.fields.reset(options.available_fields.models)
        @fields.on('change:selected',    this.setField,    this)
        @operators.on('change:selected', this.setOperator, this)
        @operator = @operators.findWhere(selected: true)
        if (field = @fields.findWhere(visible: true))
            field.selected = true
            @setField(field)

    setFromView: (type, val) ->
        if type == "fields" || type == "operators"
            this[type].get(val).selected = true
        else
            super

    setField: (field) ->
        return unless field.selected
        @operators.setField( field )
        @field = field

    setOperator: (operator) ->
        return unless operator.selected
        this.operator = operator

    remove: ->
        @collection.remove(this)

    toParam: ->
        param = {}
        op = this.operator.id
        value = this.get('value')
        value += '%' if 'like' == op
        value = parseFloat(value) if @field.type == "n"
        param[ @field.id ] = if 'eq' == op then value else { op: op, value: value }
        param


class Clauses extends Lanes.Models.Collection

    model: Clause

    initialize:(models, options) ->
        super
        @query = options.query
        @fields = options.query.fields

    session:
        field: 'state'

# needs to inherit from Base so network events will be listened to
class Lanes.Models.Query extends Lanes.Models.Base
    registerForPubSub: false

    @LIKE_QUERY_TYPES: ['string', 'code', 'visible_id']
    @LESS_THAN_QUERY_TYPES: ['integer', 'bigdec', 'number']
    @GREATER_THAN_QUERY_TYPES: ['integer', 'bigdec', 'number']

    @mergedSyncOptions: (args...) ->
        _.merge {}, args..., (a, b) ->
            return a.concat(b) if _.isArray(a)

    session:
        src:     'any'
        initialField: 'state'
        idIndex: 'number'
        initialFieldIndex: 'number'
        pageSize: { type: 'number', default: 100 }
        syncOptions: 'any'
        autoRetrieve: {type:'boolean', default: false, required: true}
        title: { type: 'string', default: 'Find Record' }
        sortField: 'object'
        defaultSort: 'any'
        changeCount: {type: 'integer', default: 0}
        sortAscending: ['boolean', true, true]

    associations:
        fields:  {collection: AvailableFields, inverse: 'query'}
        clauses: {collection: Clauses, inverse: 'query'}

    derived:
        isCollection:
            deps: ['src'], fn: -> Lanes.u.isCollection(@src)

        model:
            deps: ['src'], fn: ->
                return null unless @src
                if @isCollection then @src.model else @src

        idAttribute:
            deps: ['model'], fn: -> @model::idAttribute

        results:
            deps: ['src'], fn: ->
                if @isCollection
                    new Lanes.Models.Query.CollectionResult(this)
                else
                    new Lanes.Models.Query.ArrayResult(this, pageSize: @pageSize)

    events:
        'change:sortField':     '_updateSort'
        'change:sortAscending': '_updateSort'

    constructor: (options = {}) ->
        super

        @fields.reset()
        for col, i in options.fields
            rec = if _.isObject(col) then col else { id: col }
            @fields.add rec
            @idIndex = i if rec.id == @idAttribute
        unless @idIndex?
            @idIndex = @fields.length
            @fields.add(id: @idAttribute)
        # @clauses = new Clauses([], query: this )
        this.listenTo(@clauses, 'change remove reset', =>
            @results.reset()
            @results.ensureLoaded() if this.autoRetrieve
        )
        this.on('change:src change:results', ->
            this.trigger('load')
        )
        this.on('load', ->
            @changeCount += 1
        )

        if @initialFieldIndex
            @initialField = this.fields.visible.at(@initialFieldIndex)

        @initialField ||= this.fields.visible.findWhere(id: "code") ||
            this.fields.visible.findWhere(id: "visible_id") ||
            this.fields.visible.first()
        @reset(true)
        this

    clonedAttributes: ->
        attrs = @getAttributes(session: true, derived: false)
        attrs.fields = this.fields.serialize({session: true})
        attrs

    reset: (silent = false) ->
        unless @defaultSort is false
            sort = @defaultSort or @fields.findWhere(visible: true).id
            @setSortField( @fields.findWhere(id: sort), sortAscending: @sortAscending, silent: true )

        @clauses.reset([
            {query: this, available_fields: @fields, field: @initialField}
        ], {silent})

    setSortField: (field, options = {silent: false}) ->
        options.sortAscending ?= (if @sortField is field then !@sortAscending else true)
        @set({
            sortAscending: options.sortAscending
            sortField: field
        }, options)

    ensureLoaded: -> @results.ensureLoaded()

    isValid: ->
        ! @clauses.findWhere( isValid: false )

    loadModel: (model, options = {}) ->
        _.extend(options, _.result(this, 'syncOptions'), force: true)
        model.withAssociations(options.include || [], options)

    loadSingle: (code, options = {}) ->
        options.query = {}
        options.query[ @initialField.id ] = code
        _.extend(options, _.result(this, 'syncOptions'))
        @trigger('request')
        @src.fetch(options).then (model) =>
            @trigger('load')
            model

    defaultField: ->
        @fields.findWhere( field: @initialField )

    addNewClause: ->
        @clauses.add(query: this, available_fields: @fields, field: @initialField)

    _updateSort: _.debounce ->
        @results._updateSort()

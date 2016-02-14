##= require_self
##= require ./query/Result
##= require ./query/ArrayResult
##= require ./query/CollectionResult

class Field extends Lanes.Models.Base
    pubsub: false
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
    pubsub: false

    session:
        id:       'string'
        name:     'string'
        types:    'array'
        field:    'object'
        selected: 'boolean'

    derived:
        valid:
            deps: ['types', 'field']
            fn: ->
                !this.types || ( this.field && _.contains(this.types, this.field.type) )


class Operators extends Lanes.Models.Collection
    model: Operator

    constructor: ->
        super
        this.add([
            { id: 'like', name: 'Starts With', types:['string'] }
            { id: 'eq',   name: 'Equals' }
            { id: 'lt',   name: 'Less Than',   types:['integer', 'bigdec', 'number'] }
            { id: 'gt',   name: 'More Than',   types:['integer', 'bigdec', 'number'] }
        ])
        this.on('change', (changing) ->
            return unless changing.selected
            for model in @models
                model.selected = false unless model == changing
        )
    setField: (field) ->
        this.invoke('set', 'field', field)
        selected = this.findWhere(selected: true)
        if selected && !selected.valid
            selected.selected = false
            this.findWhere(valid:true).selected = true



class Clause extends Lanes.Models.Base
    pubsub: false

    session:
        value     : { type: 'string', default: '' }
        field     : 'state'
        operator  : 'state'

    associations:
        operators : { collection: Operators }
        fields:
            collection: AvailableFields, options: ->
                query: this.collection.query

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
        @operators.field = @fields.first()
        @fields.on('change:selected',    this.setField,    this)
        @operators.on('change:selected', this.setOperator, this)
        field = @fields.findWhere(visible: true)
        if field
            field.selected = true
            @setField(field)
            operator = @operators.find (o) -> o.valid
            operator?.selected = true

    setFromView: (type, val) ->
        if type == "fields" || type == "operators"
            this[type].get(val).selected = true
        else
            super

    setField: (field) ->
        return unless field.selected
        @operators.setField( field )
        this.field = field

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
        param[ this.field.id ] = if 'eq' == op then value else { op: op, value: value }
        param


class Clauses extends Lanes.Models.Collection

    model: Clause

    initialize:(models, options) ->
        super
        @query = options.query
        @fields = options.query.fields

# needs to inherit from Base so network events will be listened to
class Lanes.Models.Query extends Lanes.Models.Base
    pubsub: false


    @mergedSyncOptions: (args...) ->
        _.merge {}, args..., (a, b) ->
            if _.isArray(a)
                return a.concat(b)
    session:
        src:     'any'
        fields:  'collection'
        clauses: 'collection'
        initialField: 'state'
        idIndex: 'number'
        initialFieldIndex: 'number'
        pageSize: { type: 'number', default: 100 }
        syncOptions: 'any'
        autoRetrieve: ['boolean', true, true]
        title: { type: 'string', default: 'Find Record' }
        sortField: 'object'
        changeCount: {type: 'integer', default: 0}
        sortAscending: ['boolean', true, true]

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
        @fields = new AvailableFields([], query: this)
        for col, i in options.fields
            rec = if _.isObject(col) then col else { id: col }
            @fields.add rec
            @idIndex = i if rec.id == @idAttribute
        unless @idIndex?
            @idIndex = @fields.length
            @fields.add(id: @idAttribute)
        @clauses = new Clauses([], query: this )
        this.listenTo(@clauses, 'change remove reset', =>
            @results.reset()
            @results.ensureLoaded() if this.autoRetrieve
        )
        this.on('change:src change:results', ->
            this.trigger('load')
        )
        if options.defaultSort
            @setSortField( @fields.findWhere(id: options.defaultSort), true )
        if @initialFieldIndex
            @initialField = this.fields.at(@initialFieldIndex)
        @initialField ||= this.fields.findWhere(id: "code") ||
            this.fields.findWhere(id: "visibleId") ||
            this.fields.first()
        this.addNewClause()
        this

    setSortField: (field, silent = false) ->
        @set({
            sortAscending: (if @sortField is field then !@sortAscending else true)
            sortField: field
        }, {silent})

    ensureLoaded: -> @results.ensureLoaded()

    isValid: ->
        ! @clauses.findWhere( isValid: false )

    loadModel: (model, options = {}) ->
        _.extend(options, _.result(this, 'syncOptions'))
        model.withAssociations(options.include || [], options)

    loadSingle: (code, options = {}) ->
        options.query = {}
        options.query[ @initialField.id ] = code
        _.extend(options, _.result(this, 'syncOptions'))
        @src.fetch(options)

    defaultField: ->
        @fields.findWhere( field: @initialField )

    addNewClause: ->
        @clauses.add(query: this, available_fields: @fields, field: @initialField)

    _updateSort: _.debounce ->
        @results._updateSort()

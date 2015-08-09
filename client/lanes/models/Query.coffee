class Field extends Lanes.Models.Base

    constructor: (attributes) ->
        super( _.defaults( attributes, {
            title: _.titleize(_.humanize(attributes.id))
        }))

    session:
        id:       'string'
        title:    'string'
        visible:  type: 'boolean', default: true
        selected: 'boolean'
        query:    type: 'boolean', default: true
        flex:     type: 'number',  default: 1
        textAlign: type: 'string', default: 'left'

    derived:
        default_value: deps: ['id'], fn: ->
            switch @model_field.type
                when 'integer' then 0
                else ''
        model_field:
            deps: ['id'], fn: ->
                this.collection.query.src::_definition[@id]
        type:
            deps: ['model_field'], fn: ->
                type = @model_field?.type || 'string'
                if type == "code" then "string" else type

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

        @fields.findWhere(visible: true)?.selected = true
        @operators.at(0).selected = true

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

class Lanes.Models.Query extends Lanes.Models.Base

    session:
        src:  'function'
        fields:  'collection'
        clauses: 'collection'
        initialField: 'state'
        idIndex: 'number'
        initialFieldIndex: 'number'
        pageSize: 'number'
        syncOptions: 'any'
        autoRetrieve: ['bool', true, true]

    derived:
        model:
            deps: ['src'], fn: ->
                return null unless @src
                if Lanes.u.isCollection(@src) then @src.model else @src
        results:
            fn: -> new Lanes.Models.QueryResults(this, pageSize: @pageSize)
        url:
            deps:['src'], fn: ->
                if Lanes.u.isCollection(@src) then @src.url() else @src?::urlRoot()
        # collection_class:
        #     deps:['src'], fn: -> @src?.Collection

    constructor: (options = {}) ->
        super
        idName = @src::idAttribute
        @loadAssociations = options.loadAssociations
        @fields = new AvailableFields([], query: this)
        for col, i in options.fields
            rec = if _.isObject(col) then col else { id: col }
            @fields.add rec
            @idIndex = i if rec.id == idName
        unless @idIndex?
            @idIndex = @fields.length
            @fields.add(id: idName)
        @clauses = new Clauses([], query: this )
        this.listenTo(@clauses, 'change remove reset', =>
            @results.reset()
            @results.ensureLoaded() if this.autoRetrieve
        )
        if @initialFieldIndex
            @initialField = this.fields.at(@initialFieldIndex)
        @initialField ||= this.fields.findWhere(id: "code") ||
            this.fields.findWhere(id: "visibleId") ||
            this.fields.first()
        this.addNewClause()
        this

    ensureLoaded: -> @results.ensureLoaded()

    isValid: ->
        ! @clauses.findWhere( isValid: false )

    loadModelWithAssociations: (model) ->
        model.withAssociations(@loadAssociations || [], force:true)

    loadSingle: (code, options = {}) ->
        options.query = {}
        options.query[ @initialField.id ] = code
        options.include = @loadAssociations
        @src.fetch(options)

    defaultField: ->
        @fields.findWhere( field: @initialField )

    addNewClause: ->
        @clauses.add(query: this, available_fields: @fields, field: @initialField)

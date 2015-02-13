class Field extends Lanes.Models.Base

    constructor: (attributes)->
        super( _.defaults( attributes, {
            title: _.titleize(attributes.id)
        }))

    session:
        id:       'string'
        title:    'string'
        selected: 'boolean'

    derived:
        model_field:
            deps: ['id'], fn:->
                this.collection.query.modelClass::_definition[@id]
        type:
            deps: ['model_field'], fn: ->
                @model_field?.type

    validValue: (value)->
        if this.type == 'n'
            ! _.isNaN( parseFloat(value) )
        else
            value


class AvailableFields extends Lanes.Models.Collection

    constructor: (models,options)->
        @query = options.query
        super
    model: Field



class Operator extends Lanes.Models.Base

    addStandardProperties: Lanes.emptyFn

    session:
        id:       'string'
        name:     'string'
        types:    'array'
        field:    'object'
        selected: 'boolean'

    derived:
        valid:
            deps: ['types','field']
            fn: ->
                !this.types || ( this.field && _.contains(this.types, this.field.type) )


class Operators extends Lanes.Models.Collection
    model: Operator

    constructor: ->
        super
        this.add([
            { id: 'like', name: 'Starts With', types:['string'] }
            { id: 'eq',   name: 'Equals' }
            { id: 'lt',   name: 'Less Than',   types:['integer','bigdec','number'] }
            { id: 'gt',   name: 'More Than',   types:['integer','bigdec','number'] }
        ])

    setField: (field)->
        this.invoke('set', 'field', field)
        selected = this.findWhere(selected: true)
        if selected && !selected.valid
            selected.selected = false
            this.findWhere(valid:true).selected = true


class Clause extends Lanes.Models.Base

    session:
        value     : { type: 'string', default: '' }
        operators : 'collection'
        field     : 'model'
        operator  : 'model'

    derived:
        description:
            deps: ['field','operator']
            fn: -> "#{@field.title} #{@operator.id}"

        isValid:
            deps: ['field', 'operator', 'value']
            fn: -> this.field.validValue(@value)

    initialize:(attrs,options)->
        super
        @operators = new Operators
        @fields    = @collection.fields
        @operators.field = @fields.first()
        @fields.on('change:selected',    this.setField,    this)
        @operators.on('change:selected', this.setOperator, this)

        @fields.at(0).selected = true
        @operators.at(0).selected = true

        window.q = this

    setField: (field)->
        return unless field.selected
        @operators.setField( field )
        this.field = field

    setOperator: (operator)->
        return unless operator.selected
        this.operator = operator

    remove: ->
        @collection.remove(this)

    toParam: ->
        param = {}
        op = this.operator.id
        value = this.get('value')
        value +='%' if 'like' == op
        value = parseFloat(value) if @field.type == "n"
        param[ this.field.field ] = if 'eq' == op then value else { op: op, value: value }
        param


class Clauses extends Lanes.Models.Collection

    model: Clause

    initialize:(models,options)->
        super
        @query = options.query
        @fields = options.query.fields


class Lanes.Models.Query extends Lanes.Models.Base

    session:
        fields:  'collection'
        clauses: 'collection'
        collection_class: 'function'
        initial_field: 'string'

    derived:
        model_class:
            deps:['collection_class'], fn: -> @collection_class::model
        url:
            deps:['collection_class'], fn: -> @collection_class::url()

    constructor: (options={})->
        super
        @fields = new AvailableFields(
            _.map( options.fields, (col)-> if _.isObject(col) then col else { field: col } ),
            query: this
        )
        @clauses = new Clauses([], query: this )
        this.listenTo(@clauses,'change remove reset', ->
            this.trigger('change', arguments...)
        )
        @initial_field = @fields.first.field
        this.addNewClause()
        this

    isValid: ->
        ! @clauses.findWhere( isValid: false )

    loadSingle: (code,options)->
        options.query = {}
        options.query[ @initial_field ] = code
        @collection_class::model.fetch(options)

    defaultField: ->
        @fields.findWhere( field: @initial_field )

    asParams: ->
        params = {}
        @clauses.each (clause)->
            _.extend( params, clause.toParam() ) if clause.isValid

        params

    addNewClause: ->
        @clauses.add({ field: @initial_field, operator: 'like' })

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
        field     : 'state'
        operator  : 'state'

    associations:
        operators : { collection: Operators }
        fields:
            collection: AvailableFields, options: ->
                query: this.collection.query


    derived:
        description:
            deps: ['field','operator']
            fn: -> "#{@field.title} #{@operator.id}"

        isValid:
            deps: ['field', 'operator', 'value']
            fn: -> this.field.validValue(@value)

    constructor: (options)->
        super
        this.fields.reset(options.available_fields.models)
        @operators.field = @fields.first()
        @fields.on('change:selected',    this.setField,    this)
        @operators.on('change:selected', this.setOperator, this)

        @fields.at(0).selected = true
        @operators.at(0).selected = true


    setFromView: (type, val)->
        if type=="fields" || type == "operators"
            this[type].get(val).selected=true
        else
            super

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
        param[ this.field.id ] = if 'eq' == op then value else { op: op, value: value }
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
        modelClass:  'function'
        initialField: 'state'

    derived:
        collection_class:
            deps:['modelClass'], fn: -> @modelClass?.Collection
        url:
            deps:['modelClass'], fn: -> @modelClass?::urlRoot()

    constructor: (options={})->
        super
        @fields = new AvailableFields(
            _.map( options.fields, (col)-> if _.isObject(col) then col else { id: col } ),
            query: this
        )
        @clauses = new Clauses([], query: this )
        this.listenTo(@clauses,'change remove reset', ->
            this.trigger('change', arguments...)
        )
        @initialField = @fields.first()
        this.addNewClause()
        this

    isValid: ->
        ! @clauses.findWhere( isValid: false )

    loadSingle: (code,options)->
        options.query = {}
        options.query[ @initialField.id ] = code
        @modelClass.fetch(options)

    defaultField: ->
        @fields.findWhere( field: @initialField )

    asParams: ->
        params = {}
        @clauses.each (clause)->
            _.extend( params, clause.toParam() ) if clause.isValid

        params

    addNewClause: ->
        @clauses.add({ available_fields: @fields, field: @initialField })

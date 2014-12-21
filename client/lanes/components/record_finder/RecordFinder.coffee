class FinderClause
    constructor: -> super

    template: 'record-finder/clause'

    initialize: ->
        window.fc = this.model

    events:
        'hidden.bs.dropdown': 'onQueryChange'
        'click .del-clause': 'delClause'
        'input input.query-string': 'onInput'

    onInput: (ev)->
        this.model.value = ev.target.value

    bindings:
        'model.description': '.query-field-description'

    subviews:
        fields:
            component: 'RadioGroup'
            data: 'model.fields'
            container: '.fields'
            options: { mappings: { id:'field'}, access: 'write' }

        operators:
            component: 'RadioGroup'
            data: 'model.operators'
            container: '.operators'
            options: { mappings: { title:'name', visible: 'valid' }, access: 'write' }

    delClause: ->
        @model.remove()

    onQueryChange: ->
        this.$('input.query-string').focus()

    render: ->
        super
        @defer @focus, delay: 500
        this

    focus: ->
        this.$('input.query-string').focus()


Lanes.Component.Base.extend(FinderClause)


class FinderDialog
    constructor: ->
        super

    events:
        'click .add-clause': 'addClause'
        'click .run-query':  'runQuery'
        'select-row .skr-grid': 'onSelect'

    subviews:
        grid:
            hook: 'grid'
            component: 'Grid'
            options: ->
                { record_query: @record_query }
        query_clauses:
             container: '.query-clauses'
             view: FinderClause, collection: 'clauses'

    bodyTemplateName: 'record-finder/dialog'
    bodyAttributes:
        class: "record-finder"

    session:
        record_query: 'model'
        clauses: 'collection'

    initialize:(options)->
        # @record_query = options.record_query
        # @columns     = options.columns
        # @model_type  = options.model_type

        @clauses = @record_query.clauses

        @debounceMethod( 'runQuery')
        this.listenTo(@record_query,'change',@runQuery)
        _.bindAll(this,'hide')

    onSelect: (ev)->
        @record = ev.detail.model
        ev.preventDefault()
        _.delay(this.hide, 500)

    addClause: ->
        @record_query.addNewClause()

    runQuery: ->
        this.grid.reload() if @record_query.isValid()

Lanes.Component.ModalDialog.extend(FinderDialog)


class RecordFinder
    constructor: -> super
    template: 'record-finder/field'
    templateModels: -> { field_name: @record_query.initial_field }

    events:
        "keyup .record-finder-query-string": "onKey"
        "click .record-finder-query": "displayFinder"

    session:
        include_associations: 'array'
        record_query: 'model'
        query_field: [ 'string', false, 'code' ]

    initialize:(options)->
        @record_query = new Lanes.Models.Query(fields: options.fields, collection_class: options.query_using)

    displayFinder: ->
        finder = new FinderDialog( title: @title, record_query: @record_query )

        finder.show().then( (dlg)->
            dlg.remove().record
        ).then( (record)=>
            record.withAssociations(@.includeAssociations...) if record
        ).then( (record)=>
            this.$el.trigger("display-record", record) if record
        , (e)->Lanes.warn(e) )

    onKey: (ev)->
        qf=this.$('.record-finder-query-string')
        if 13 == ev.keyCode
            this.runQuery(ev)
        else if qf.val().match( Lanes.Models.mixins.Lanes.sCodeField.INVALID )
            qf.val( qf.val().replace( Lanes.Models.mixins.Lanes.sCodeField.INVALID, '' ) )

    runQuery: (ev)->
        code = this.$(ev.target).val()
        @record_query.loadSingle(code.toUpperCase(),{ include: @includeAssociations })
            .then( (reply)=> this.$el.trigger("display-record", reply.record) if reply.record )

Lanes.Component.RecordFinder = Lanes.Component.Base.extend(RecordFinder)

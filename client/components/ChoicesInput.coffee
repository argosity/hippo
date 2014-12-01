class Lanes.Component.ChoicesInput extends Lanes.Component.Base

    session:
        selections: 'collection'

    subViewOptions: ->
        { field_name: @field_name, mappings: @mappings }

    constructor: (options={})->
        if options.has_many
            @association = options.model.associations[options.has_many]
            @field_name  = @association.fk
        else
            @field_name = options.field_name || options.subViewId

        @mappings = _.extend({
            id: 'id', title: 'title', selected: 'selected'
        },options.mappings||{})
        super


    initialize: (options={})->
        if @association
            collection = Lanes.Data[@association.model].sharedCollection()
            collection.fetch().then (m)=>
                @selections = m
                this.on('change:model', this.onModelChange )
        else if options.data
            @selections = options.data

    selectionForID: (id)->
        q={}; q[@mappings.id]=id
        @selections.findWhere( q )

    onAttributeChange: (model,fkid)->
        this.select( this.selectionForID( fkid ) )

    onModelChange: ->
        if (old_model = this.previousAttributes()['model'])
            this.stopListening(old_model,"change:#{@association.fk}", this.onAttributeChange )
        this.listenTo(@model,"change:#{@association.fk}", this.onAttributeChange )
        fk_id = @model.get( @association.fk )
        record = if fk_id
            this.selectionForID( fk_id )
        else
            @model[@association.name]
        this.select(record)

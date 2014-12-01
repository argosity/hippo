class SelectOption extends Lanes.Views.Base
    template: (scope)->
        '<option></option>'

    constructor: (options)->
        @groupName=options.groupName
        m = options.mappings
        @bindings = {}
        @bindings["model.#{m.id}"]       = { type: 'value', selector: 'option' }
        @bindings["model.#{m.selected}"] = { type: 'booleanAttribute', selector: 'option', name:'selected' }
        @bindings["model.#{m.title}"]    = 'option'
        @bindings["model.#{m.visible}"]  = { type: 'toggle' } if m.visible
        super


class Lanes.Components.SelectField extends Lanes.Components.Base

    subviews:
        fields:
            hook: 'choices-input'
            collection: 'selections'
            options: 'subViewOptions'
            view: SelectOption

    session:
        multiple: { type: 'boolean', default: false }
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

    writeTemplate: ->
        multiple = if this.multiple then "multiple" else ""
        "<select class='form-control' #{multiple} name='#{this.field_name}' data-hook='choices-input'></select>"

    readTemplate: ->
        "<div class='ro-input' name='#{this.field_name}'></div>"

    select: (option)->
        if this.readOnly
            this.$el.text( if option then option.code else "" )
        else if option
            id = option.get(@mappings.id)
            option = this.query("option[value=\"#{id}\"]")
            option.selected = true
        else
            this.$el.find(":selected").prop('selected',false)

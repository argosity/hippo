# provides common code for both RadioGroup and SelectField
#
class Lanes.Components.MultiSelect extends Lanes.Components.Base
    session:
        multiple: { type: 'boolean', default: false }
        selections: 'collection'
        defaultID: 'integer'
        association: 'string'
        mappings: 'object'

    constructor: (options={})->
        if options.model
            if options.association && ! options.field_name
                options.field_name = options.model.associations.pk(options.association)
            if options.field_name
                listener = {}
                listener["change:#{options.field_name}"] ='onModelAttributeChange'
                this.modelEvents = _.extend( listener, this.modelEvents||{} )

        super

        if @association
            klass = options.model.associations.getClassFor(@association)
            @selections = if klass::isCollection then new klass else new klass.Collection

        if options.choices
            @selections ||= options.choices

        @selections?.ensureLoaded?().then =>
            @selectDefault()

        @mappings = _.extend({
            id: 'id', title: 'code', selected: 'selected'
        },options.mappings||{})
        if @association && !@defaultID
            pk = options.model[ options.model.associations.pk(this.association) ]
            @defaultID ||= pk

    selectDefault: ->
        if @defaultID
            selection = this.selectionForID(@defaultID)
        else
            selection = _.result(this.selections,'first')
        this.select(selection) if selection

    onRender: ->
        this.selectDefault()

    unSelectAll: ->
        this.$el.find(":selected").prop('selected',false)

    onModelChange: ->
        this.unSelectAll()
        if @selections && @model
            this.onModelAttributeChange(@model,@model.get(@field_name))

    selectionForID: (id)->
        q={}; q[@mappings.id]=id
        @selections.findWhere( q )

    onModelAttributeChange: (model,fkids)->
        if ! this.el.binding_is_setting
            fkids = [fkids] unless _.isArray(fkids)
            for fkid in fkids
                this.select(selection) if selection=this.selectionForID( fkid )

# provides common code for both RadioGroup and SelectField
#
class Lanes.Components.MultiSelect extends Lanes.Components.Base
    session:
        multiple: { type: 'boolean', default: false }
        selections: 'collection'
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

        @selections.ensureLoaded()

        @mappings = _.extend({
            id: 'id', title: 'title', selected: 'selected'
        },options.mappings||{})


    onModelChange: ->
        if @selections
            this.onModelAttributeChange(@model,@model.get(@field_name))

    selectionForID: (id)->
        q={}; q[@mappings.id]=parseInt(id)
        @selections.findWhere( q )

    onModelAttributeChange: (model,fkid)->
        if ! this.el.binding_is_setting
            this.select( this.selectionForID( fkid ) )

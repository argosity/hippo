#= require ../multi-select/MultiSelect

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


class Lanes.Components.SelectField extends Lanes.Components.MultiSelect

    subviews:
        fields:
            hook: 'choices-input'
            collection: 'selections'
            options: 'subViewOptions'
            view: SelectOption

    session:
        multiple: { type: 'boolean', default: false }

    subViewOptions: ->
        { field_name: @field_name, mappings: @mappings }

    ui:
        select: 'select'

    domEvents:
        'change' : 'onSelectChange'

    onSelectChange: (ev)->
        if @model && @association
            selection = this.selectionForID(parseInt(this.ui.select.val()))
            @model.set(@association, selection) if selection

    writeTemplate: ->
        multiple = if this.multiple then "multiple" else ""
        "<div><select class='form-control' #{multiple} name='#{this.field_name}' data-hook='choices-input'></select></div>"

    readTemplate: ->
        "<div class='ro-input' name='#{this.field_name}'></div>"

    select: (option)->
        if this.readOnly
            this.$el.text( if option then option[@mappings.title] else "" )
        else if option
            id = option.get(@mappings.id)
            option = this.query("option[value=\"#{id}\"]")
            if option
                if option.selected
                    this.onSelectChange() # force event to fire
                else
                    option.selected = true
        else
            this.unSelectAll()

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


class Lanes.Component.SelectField extends Lanes.Component.ChoicesInput

    subviews:
        fields:
            hook: 'choices-input'
            collection: 'selections'
            options: 'subViewOptions'
            view: SelectOption

    session:
        multiple: { type: 'boolean', default: false }

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

class Lanes.Component.TaggedField extends Lanes.Component.ChoicesInput

    writeTemplate: ->
        multiple = if this.multiple then "multiple" else ""
        "<select class='form-control' #{multiple} name='#{this.field_name}' data-hook='choices-input'></select>"

    readTemplate: ->
        "<div class='ro-input' name='#{this.field_name}'></div>"

    session:
        options: 'object'

    initialize: (options)->
        this.options=options.fieldOptions

    onRender: ->
        this.$el.magicSuggest(this.options)

    # select: (option)->
    #     if this.readOnly
    #         this.$el.text( if option then option.code else "" )
    #     else if option
    #         id = option.get(@mappings.id)
    #         option = this.query("option[value=\"#{id}\"]")
    #         option.selected = true
    #     else
    #         this.$el.find(":selected").prop('selected',false)

class RadioInput
    template: (scope)->
        '<label><input type="radio" name="' + scope.field_name + '"/> <span></span></label>'

    #bindings: {}

    constructor: (options)->
        @field_name=options.field_name
        m = options.mappings
        @bindings = {}
        @bindings["model.#{m.id}"]       = { type: 'value', selector: 'input' }
        @bindings["model.#{m.selected}"] = { type: 'booleanAttribute', selector: 'input', name:'checked' }
        @bindings["model.#{m.title}"]    = 'span'
        @bindings["model.#{m.visible}"]  = { type: 'toggle' } if m.visible
        super


Lanes.Views.Base.extend(RadioInput)


class RadioGroup
    constructor: -> super

    events:
        'change input': 'onInputChange'

    writeTemplate: ->
        "<span data-hook='choices-input'></span>"

    subviews:
        fields:
            hook: 'choices-input'
            collection: 'selections'
            options: 'subViewOptions'
            view: RadioInput


    initialize: ->
        super
        this.listenTo(@selections, "change", this.onSelectionChange) if @selections

    onSelectionChange: (option)->
        return unless option[@mappings.selected]
        @selections.each( (other_option)->
            other_option[@mappings.selected] = other_option[@mappings.id] == option[@mappings.id]
        ,this)

    onInputChange: (ev)->
        @selections.each( (option)->
            option[@mappings.selected] = option[@mappings.id] == ev.target.value
        ,this)

    getSelected: ->
        q={}
        q[@mappings.selected]=true
        @selections.findWhere(q)


Lanes.Component.RadioGroup = Lanes.Component.ChoicesInput.extend(RadioGroup)

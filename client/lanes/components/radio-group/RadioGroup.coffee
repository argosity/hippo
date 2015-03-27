#= require ../multi-select/MultiSelect

class RadioInput extends Lanes.Views.Base
    template: ->
        '<label><input type="radio" name="' + this.field_name + '"/> <span></span></label>'

    constructor: (options)->
        @field_name=options.field_name
        m = options.mappings
        @bindings = {}
        @bindings["model.#{m.id}"]       = { type: 'value', selector: 'input' }
        @bindings["model.#{m.selected}"] = { type: 'booleanAttribute', selector: 'input', name:'checked' }
        @bindings["model.#{m.title}"]    = 'span'
        @bindings["model.#{m.visible}"]  = { type: 'toggle' } if m.visible
        super


class Lanes.Components.RadioGroup extends Lanes.Components.MultiSelect


    writeTemplate: ->
        "<span data-hook='choices-input'></span>"

    subviews:
        fields:
            hook: 'choices-input'
            collection: 'selections'
            waitFor: 'selections'
            view: RadioInput
            options: 'subViewOptions'

    constructor: (options)->
        super

    subViewOptions: ->
        { field_name: @field_name, mappings: @mappings }

    onSelectionChange: (option)->
        return unless option[@mappings.selected]
        @selections.each( (other_option)->
            other_option[@mappings.selected] = other_option[@mappings.id] == option[@mappings.id]
        ,this)

    getSelected: ->
        q={}
        q[@mappings.selected]=true
        @selections.findWhere(q)

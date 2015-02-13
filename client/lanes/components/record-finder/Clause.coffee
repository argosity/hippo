class Lanes.Components.RecordFinder.Clause extends Lanes.Components.Base
    FILE: FILE

    writeTemplateName: 'clause'
    useFormBindings: true
    domEvents:
        'hidden.bs.dropdown': 'onQueryChange'
        'click .del-clause': 'delClause'
        'input input.query-string': 'onInput'

    onInput: (ev)->
        this.model.value = ev.target.value

    bindings:
        'model.description': '.query-field-description'

    subviews:
        fields:
            component: 'RadioGroup', model:'model',
            options: -> { choices: @model.fields, field_name: 'fields', access: 'write' }

        operators:
            component: 'RadioGroup', model: 'model'
            options: -> { choices: @model.operators, field_name: 'operators', mappings: { title:'name', visible: 'valid' }, access: 'write' }

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

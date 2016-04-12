Lanes.Components.Form.InputFieldMixin =

    mixins: [
        Lanes.Components.Form.FieldMixin
    ]

    propTypes:
        unlabled:     React.PropTypes.bool
        onlyNumeric:  React.PropTypes.bool
        selctOnFocus: React.PropTypes.bool

    getDefaultProps: ->
        type: 'text'

    getValue: ->
        @refs.input.getValue() or ''

    handleKeyDown: (ev) ->
        @props.onEnter() if ev.key is 'Enter'

    selectOnFocus: (ev) ->
        ev.target.select()

    onFieldBlur: ->
        @onFieldInteraction()
        @props.onBlur?()

    renderEdit: (label) ->
        value = @props.value or @_getValue() or ''

        props = _.extend({
            ref:       'input'
            className: _.classnames('edit',
                changeset: @state.changeset
            )

            label:     if @props.unlabeled then false else label
            onChange:  @handleChange
        }, @props, {value: value})

        handlers = { onBlur: @onFieldBlur }

        if @isFieldValueInvalid() then props.bsStyle   = 'error'
        if @props.onEnter         then handlers.onKeyDown = @handleKeyDown
        if @props.selectOnFocus   then handlers.onFocus   = @selectOnFocus

        props = _.omit(props, 'label')
        field = @renderInputField(props, handlers)

        if props.inputOnly
            field
        else
            label ||= @props.label or _.field2title(@props.name)

            <LC.FormGroup display {...props} label={label}>
                {field}
            </LC.FormGroup>

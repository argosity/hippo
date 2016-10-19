Lanes.Components.Form.InputFieldMixin =

    mixins: [
        Lanes.Components.Form.FieldMixin
    ]

    propTypes:
        onlyNumeric:  React.PropTypes.bool
        selctOnFocus: React.PropTypes.bool
        onEnter: React.PropTypes.func

    focus: ->
        _.dom(@, 'input').el.focus()

    getDefaultProps: ->
        type: 'text'

    handleKeyDown: (ev) ->
        @props.onEnter() if ev.key is 'Enter'

    selectOnFocus: (ev) ->
        ev.target.select()

    onFieldBlur: ->
        @onFieldInteraction()
        @props.onBlur?()

    renderEdit: (props) ->
        props = _.extend(props, {
            ref: 'input'
            name: @props.name
            value: @fieldMixinGetValue()
        })

        handlers = { onBlur: @onFieldBlur }

        if @props.onEnter         then handlers.onKeyDown = @handleKeyDown
        if @props.selectOnFocus   then handlers.onFocus   = @selectOnFocus

        props = Lanes.u.cleanBsSizes(props)

        @renderInputField(props, handlers)

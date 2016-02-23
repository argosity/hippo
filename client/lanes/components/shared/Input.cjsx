class Lanes.Components.Input extends Lanes.React.Component

    NUMBER_TEST: /^-?\d+(\.\d+)?$/

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
        @refs.input.getValue()

    handleKeyDown: (ev) ->
        @props.onEnter() if ev.key is 'Enter'

    valueInFlux: (value) ->
        type = @props.model.attributeType(@props.name)
        (@props.onlyNumeric or type is "bigdec" ) and not @NUMBER_TEST.test(value)

    validatedChangeHandler: (ev) ->
        value = ev.target.value
        if @valueInFlux(value)
            @setState(pendingValue: value)
        else
            @setState(pendingValue: false)
            @handleChange(ev)

    selectOnFocus: (ev) ->
        ev.target.select()

    onFieldBlur: ->
        @onFieldInteraction()
        @props.onBlur?()

    renderEdit: (label) ->
        value = @state.pendingValue or @props.value or @_getValue()
        label ||= @props.label or _.field2title(@props.name)

        props = _.extend({
            ref:       'input'
            className: _.classnames('value', changeset: @state.changeset)
            label:     if @props.unlabeled then false else label
            onChange:  @validatedChangeHandler
        }, @props, {value: value})

        handlers = { onBlur: @onFieldBlur }

        if @isFieldValueInvalid() then props.bsStyle   = 'error'
        if @props.onEnter         then handlers.onKeyDown = @handleKeyDown
        if @props.selectOnFocus   then handlers.onFocus   = @selectOnFocus

        if @props.inputOnly then @renderPlain(props, handlers) else @renderStyled(props, handlers, label)

    renderPlain: (props, handlers) ->
        <input {...props} {...handlers} />

    renderStyled: (props, handlers, label) ->

        colProps = _.omit(props, 'name')

        <BS.Col {...colProps} >
            <BS.Input {...props} {...handlers} />
        </BS.Col>

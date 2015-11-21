class Lanes.Components.Input extends Lanes.React.Component

    NUMBER_TEST: /^-?\d+(\.\d+)?$/

    mixins: [
        Lanes.Components.Form.FieldMixin
    ]

    propTypes:
        unlabled:  React.PropTypes.bool
        onlyNumeric: React.PropTypes.bool

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

    renderEdit: (label) ->
        value = @state.pendingValue or @props.value or @_getValue()
        label ||= @props.label or _.field2title(@props.name)
        props = _.extend({
            ref:       'input'
            className: _.classnames('value', changeset: @state.changeset)
            label:     if @props.unlabeled then false else label
            value:     value
            onKeyDown: @handleKeyDown if @props.onEnter
            onChange:  @validatedChangeHandler
        }, @props, {value: value})
        if @props.inputOnly then @renderPlain(props) else @renderStyled(props, label)

    renderPlain: (props) ->
        <input {...props}/>

    renderStyled: (props, label) ->
        colProps = _.omit(props, 'name')
        <BS.Col {...colProps} >
            <BS.Input {...props} />
        </BS.Col>

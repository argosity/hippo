class Lanes.Components.Input extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.InputFieldMixin
    ]

    renderInputField: (props, handlers, label) ->
        if @props.inputOnly then @renderPlain(props, handlers) else @renderStyled(props, handlers, label)

    renderPlain: (props, handlers) ->
        <input {...props} {...handlers} />

    renderStyled: (props, handlers, label) ->
        colProps = _.omit(@props, 'name', 'label', 'type', 'editing', 'display')

        colClassName = _.classnames("align-#{@props.align}": @props.align, @formGroupClassNames(), 'field')
        <BS.Col {...colProps} className={colClassName}>
            <BS.Input {...props} {...handlers} />
        </BS.Col>

class Lanes.Components.TextArea extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.InputFieldMixin
    ]

    renderInputField: (props, handlers) ->
        className = _.classnames(props.className, 'form-control')
        <textarea
            {...props}
            {...handlers}
            className={className}
            onChange={@fieldMixinSetValue}
        />

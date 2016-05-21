class Lanes.Components.TextArea extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.InputFieldMixin
    ]

    renderInputField: (props, handlers) ->
        className = _.classnames(props.className, 'form-control')
        <textarea
            {...props}
            {...handlers}
            {..._.pick(@props, 'placeholder')}
            className={className}
            onChange={@fieldMixinSetValue}
        />

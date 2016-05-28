class Lanes.Components.Input extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.InputFieldMixin
    ]

    renderInputField: (props, handlers) ->
        <BS.FormControl
            type={@props.type or 'text'}
            {...props}
            {...handlers}
            onChange={@fieldMixinSetValue}
        />

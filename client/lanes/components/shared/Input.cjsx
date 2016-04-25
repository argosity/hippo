class Lanes.Components.Input extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.InputFieldMixin
    ]

    renderInputField: (props, handlers) ->
        <BS.FormControl
            {...props}
            {...handlers}
            onChange={@fieldMixinSetValue}
        />

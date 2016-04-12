class Lanes.Components.Input extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.InputFieldMixin
    ]

    renderInputField: (props, handlers) ->
        <BS.Input standalone {...props} {...handlers} />

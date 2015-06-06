class Lanes.Components.RadioField extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.FieldMixin
    ]

    renderEdit: ->
        <BS.Col {...@props}>
            <BS.Input
                type="radio"
                checked={@props.checked? || @props.value == @model[@props.name]}
                onChange={@handleChange}
                {...@props} />
        </BS.Col>

class FakeInputEvent
    constructor: (value) ->
        @target = {value}
    isDefaultPrevented: -> false


class Lanes.Components.RadioField extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.FieldMixin
    ]

    handleRadioChange: (ev) ->
        if ev.target.checked
            @fieldMixinSetValue( new FakeInputEvent(@props.value) )

    renderEdit: (props, handlers) ->
        <BS.FormControl
            {...props}
            {...handlers}
            type="radio"
            checked={@props.checked? || @props.value == @model[@props.name]}
            onChange={@handleRadioChange}
        />

class FakeInputEvent
    constructor: (value) ->
        @target = {value}
    isDefaultPrevented: -> false


class Lanes.Components.Checkbox extends Lanes.React.Component

    propTypes:
        supportIndeterminate: React.PropTypes.bool

    componentDidMount:  -> @updateIndeterminate()
    componentDidUpdate: -> @updateIndeterminate()

    mixins: [
        Lanes.Components.Form.InputFieldMixin
    ]

    updateIndeterminate: ->
        return unless @props.supportIndeterminate
        _.dom(@).el.indeterminate =
            @props.checked isnt true and @props.checked isnt false

    handleCheckboxChange: (ev) ->
        if ev.target.checked
            @fieldMixinSetValue( new FakeInputEvent(@props.value) )

    renderInputField: (props, handlers) ->
        <input type="checkbox"
            {...handlers}
            {...props}
            checked={@props.checked}
            onChange={@handleCheckboxChange}
        />

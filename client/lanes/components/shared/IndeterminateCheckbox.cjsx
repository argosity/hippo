class Lanes.Components.IndeterminateCheckbox extends Lanes.React.Component

    componentDidMount:  -> @updateIndeterminate()
    componentDidUpdate: -> @updateIndeterminate()

    updateIndeterminate: ->
        _.dom(@).el.indeterminate =
            @props.checked isnt true and @props.checked isnt false

    handleCheckboxChange: (ev) ->
        if ev.target.checked
            @fieldMixinSetValue( new FakeInputEvent(@props.value) )

    render: ->
        <input type="checkbox"
            {...@props}
            checked={@props.checked}
            onChange={@props.onChange}
        />

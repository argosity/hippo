class Lanes.Components.ToggleField extends Lanes.React.Component
    mixins: [ Lanes.Components.Form.FieldMixin ]

    fieldClassName: 'toggle'

    handleToggleChange: (ev) ->
        @props.model[@props.name] = ev.target.checked
        null

    renderDisplay: (props) ->
        props = Lanes.u.cleanBsSizes(props)
        <Lanes.Vendor.ReactToggle
            {...props}
            checked={!!@props.model[@props.name]}
            disabled={true}
        />

    renderEdit: (props) ->
        props = Lanes.u.cleanBsSizes(props)
        <Lanes.Vendor.ReactToggle
            {...props}
            onChange={@handleToggleChange}
            checked={!!@props.model[@props.name]}
        />

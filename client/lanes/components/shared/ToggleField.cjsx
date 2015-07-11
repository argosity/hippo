class Lanes.Components.ToggleField extends Lanes.React.Component
    mixins: [ Lanes.Components.Form.FieldMixin ]

    formGroupClass: 'toggle'

    renderDisplayValue: ->
        <Lanes.Vendor.ReactToggle
            defaultChecked={!!@props.model[@props.name]}
            disabled={true}
        />


    handleToggleChange: (ev) ->
        @props.model[@props.name] = ev.target.checked
        null

    renderEdit: (label) ->
        props = _.omit(@props, 'label')
        toggle = <Lanes.Vendor.ReactToggle
            defaultChecked={!!@props.model[@props.name]}
            onChange={@handleToggleChange}
            {...props} />
        if @props.unstyled
            toggle
        else
            colProps = _.omit(@props, 'name', 'label')
            <BS.Col {...colProps}>
                <div className={@formGroupClasseNames()}>
                    <label className="control-label">{label}</label>
                    <div className="value">
                        {toggle}
                    </div>
                </div>
            </BS.Col>

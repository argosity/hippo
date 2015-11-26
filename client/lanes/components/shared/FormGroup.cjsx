class Lanes.Components.FormGroup extends Lanes.React.BaseComponent

    render: ->
        colProps = _.omit(@props, 'name', 'label')
        <BS.Col {...colProps} className='form-group'>
            <label className="control-label">
                {@props.label}
            </label>
            {@props.children}
        </BS.Col>

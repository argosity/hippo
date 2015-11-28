class Lanes.Components.FormGroup extends Lanes.React.BaseComponent

    render: ->
        className = _.classnames(className, @props.className, "field"
            editing: @props.editing
            display: false == @props.editing
        )

        colProps = _.omit(@props, 'name', 'label', 'type', 'editing', 'display')

        <BS.Col {...colProps} className={className}>
            <div className="form-group">
                <label className="control-label">
                    <span>{@props.label}</span>
                </label>
                <div className="input-group" name={@props.name}>
                    <div className="value">{@props.children}</div>
                </div>
            </div>
        </BS.Col>

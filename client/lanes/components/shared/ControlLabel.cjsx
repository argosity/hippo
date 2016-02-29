class InvalidTag extends Lanes.React.BaseComponent

    mixins: [
        Lanes.React.Mixins.ReadEditingState
        Lanes.React.Mixins.FieldErrors
        Lanes.React.Mixins.Viewport
    ]

    render: ->
        return null unless (invalidMsg = @fieldInvalidValueMessage())
        tooltip =
            <BS.Tooltip id="error-tooltip">{invalidMsg}</BS.Tooltip>
        <BS.OverlayTrigger
            delayShow={300} delayHide={150} container={@context.viewport.lanes}
            placement="top" overlay={tooltip}
        >
            <span ref='target'>
                <LC.Icon ref='target' type='exclamation-triangle' className='error' />
            </span>
        </BS.OverlayTrigger>

class Lanes.Components.ControlLabel extends Lanes.React.Component

    mixins: [
        Lanes.React.Mixins.ReadEditingState
        Lanes.React.Mixins.FieldErrors
    ]

    propTypes:
        model: Lanes.PropTypes.State
        invalidMsg: React.PropTypes.string
    focusInput: (ev) ->
        _.dom(ev.target).closest('.form-group')
            .qs('input', raise: false).focusAndSelect()
    render: ->
        if @props.titleOnly
            <span className="label-title-only">
                {@props.label}
                <InvalidTag {...@props} />
            </span>
        else
            <label className="control-label" onClick={@focusInput}>
                <span className="label-title">{@props.label}</span>
                <InvalidTag {...@props} />
            </label>

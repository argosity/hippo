class Lanes.Components.Tooltip extends Lanes.React.Component

    TTProps: [
        'id', 'placement', 'positionLeft', 'positionTop',
        'arrowOffsetLeft', 'arrowOffsetTop'
    ]

    render: ->
        ttprops = _.pick(@props, @TTProps...)
        tooltip = <BS.Tooltip {...ttprops}>{@props.content}</BS.Tooltip>
        <BS.OverlayTrigger
            overlay={tooltip}
            placement='left'
            container={@context.viewport.lanes}
            {...@props}
        >
            {@props.children}
        </BS.OverlayTrigger>

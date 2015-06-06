class Lanes.Components.Tooltip extends Lanes.React.Component

    TTProps: ['placement', 'positionLeft', 'positionTop', 'arrowOffsetLeft', 'arrowOffsetTop']

    render: ->
        ttprops = _.pick(@props, @TTProps...)
        tooltip = <BS.Tooltip {...ttprops}>{@props.content}</BS.Tooltip>
        <BS.OverlayTrigger overlay={tooltip} container={@context.viewport.root}>
            {@props.children}
        </BS.OverlayTrigger>

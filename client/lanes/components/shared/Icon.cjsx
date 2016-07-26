DEFAULT_TOOLTIP_PROPS = { placement: 'top', trigger: 'click' }

class Lanes.Components.Icon extends Lanes.React.BaseComponent

    propTypes:
        type:         React.PropTypes.string.isRequired
        animated:     React.PropTypes.bool
        spinner:      React.PropTypes.bool
        className:    React.PropTypes.string
        tooltip:      React.PropTypes.oneOfType([
            React.PropTypes.string, React.PropTypes.element
        ])
        tooltipProps: React.PropTypes.object

    getInitialState: ->
        uniqueId: _.uniqueId('icon-tooltip-')

    getDefaultProps: ->
        tooltipProps: DEFAULT_TOOLTIP_PROPS

    render: ->
        classes = _.classnames 'icon', "icon-#{@props.type}", @props.className,
            'non-printable': @props.noPrint,
            'with-action' : @props.onClick,
            "icon-#{@props.size}" : @props.size,
            'icon-pulse' : @props.animated
            'icon-spin'  : @props.spin or @props.type is 'spinner'
            'flush'      : @props.flush
            'icon-lg'    : @props['lg']
            'icon-2x'    : @props['2x']
            'icon-3x'    : @props['3x']
            'icon-4x'    : @props['4x']
            'icon-5x'    : @props['5x']
            'clickable'  : @props.tooltip and @props.tooltipProps.trigger is 'click'

        icon =
            <i style={@props.style} className={classes} />

        if @props.tooltip
            props = _.extend({}, @props.tooltipProps, DEFAULT_TOOLTIP_PROPS)
            <LC.Tooltip id={@state.uniqueId}
                content={@props.tooltip}
                {...props}
            >
                {icon}
            </LC.Tooltip>
        else
            icon

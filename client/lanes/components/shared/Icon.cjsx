class Lanes.Components.Icon extends Lanes.React.BaseComponent

    propTypes:
        type: React.PropTypes.string.isRequired
        animated: React.PropTypes.bool

    render: ->

        classes = _.classnames 'icon', "icon-#{@props.type}", @props.className,
            'non-printable': @props.noPrint,
            'with-action' : @props.onClick,
            "icon-#{@props.size}" : @props.size,
            'icon-pulse' : @props.animated
            'flush'      : @props.flush
            'icon-lg'    : @props['lg']
            'icon-2x'    : @props['2x']
            'icon-3x'    : @props['3x']
            'icon-4x'    : @props['4x']
            'icon-5x'    : @props['5x']

        <i {...@props} style={@props.style} className={classes} />

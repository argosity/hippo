class Lanes.Components.Icon extends Lanes.React.Component

    propTypes:
        type: React.PropTypes.string.isRequired
        animated: React.PropTypes.bool

    render: ->

        classes = _.classnames 'icon', "icon-#{@props.type}", @props.className,
            'cursor-pointer'      : @props.onClick,
            "icon-#{@props.size}" : @props.size,
            'icon-pulse'          : @props.animated

        <i {...@props} className={classes} />

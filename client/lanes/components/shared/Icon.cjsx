class Lanes.Components.Icon extends Lanes.React.Component

    propTypes:
        type: React.PropTypes.string.isRequired
        animated: React.PropTypes.bool

    render: ->
        classes = _.classnames(
            'icon', "icon-#{@props.type}",
            {"icon-pulse": @props.animated}
        )
        <i className={classes} />

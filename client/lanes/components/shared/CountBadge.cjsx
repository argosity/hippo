class Lanes.Components.CountBadge extends Lanes.React.Component

    propTypes:
        count: React.PropTypes.number


    render: ->
        classes = _.classnames('count', super: @props.superScript?)
        <BS.Badge className={classes}>{@props.count}</BS.Badge>

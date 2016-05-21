class Lanes.Components.ScreenWrapper extends Lanes.React.Component

    propTypes:
        identifier: React.PropTypes.string.isRequired

    render: ->
        classes = _.classnames(
            'screen-wrapper',  @props.identifier,
            'flex-vertically': @props.flexVertical
        )
        <div className={classes} style={@props.style}>
            {@props.children}
        </div>

##= require ./EditingMixin

Lanes.Components.Grid.PopoverMixin = {

    mixins: [
        Lanes.Components.Grid.EditingMixin
    ]

    propTypes:
        width:  React.PropTypes.number.isRequired
        height: React.PropTypes.number.isRequired

    getDefaultProps: ->
        width:  280, height: 350

    renderPopover: (child) ->
        props = _.extend({}, @props)
        {position} = @props
        if position.left > ((position.container.width / 2) - 150)
            props.placement = 'left'
            props.positionLeft = position.left - @props.width
        else
            props.placement = 'right'
            props.positionLeft = position.left
        props.arrowOffsetTop = Math.min(position.top, (@props.height - 75))
        props.positionTop    = Math.max(5, position.top - props.arrowOffsetTop + (position.rowHeight / 2))

        <div className="editor po">
            <BS.Popover
                id="editing-form"
                {...props}
                style={height: @props.height, width: @props.width}
                title = "Edit #{@model.name || 'Record'}"
            >
                {@renderEditingBody()}
            </BS.Popover>
        </div>
}

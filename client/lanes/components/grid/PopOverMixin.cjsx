##= require ./EditingMixin

Lanes.Components.Grid.PopoverMixin = {

    mixins: [
        Lanes.Components.Grid.EditingMixin
    ]

    renderPopover: (child) ->
        props = if @props.editingEl
            xpos = @props.editingEl.offsetLeft + this.props.editingEl.scrollWidth / 2
            if @props.editingEl.offsetLeft + 20 > @props.grid.width() / 2
                { placement: 'left', positionLeft: @props.editingEl.offsetLeft }
            else
                { placement: 'right', positionLeft: @props.editingEl.offsetLeft + (this.props.editingEl.offsetWidth / 2) }
        else
            { placement: 'right', positionLeft: 200 }
        <div className="editor po">
            <BS.Popover
                {...props}
                positionTop={@topOffset() - 100}
                arrowOffsetTop={100 + @props.rowHeight / 2}
                title = "Edit #{@model.name || 'Record'}"
            >
                {@renderEditingBody()}
            </BS.Popover>
        </div>
}

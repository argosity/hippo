class Lanes.Components.Grid.PopoverEditor extends Lanes.React.Component

    mixins: [Lanes.Components.Grid.Editing]

    render: ->
        <div className="editor po">
            <BS.Popover
                placement    ='right'
                positionLeft ={200}
                positionTop={@topOffset() - 100}
                arrowOffsetTop={100 + @props.rowHeight / 2}
                title = "Edit #{@model.name || 'Record'}"
            >
                {@renderBody()}
            </BS.Popover>
        </div>

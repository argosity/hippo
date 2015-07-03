class Lanes.Components.Grid.RowEditor extends Lanes.React.Component

    mixins: [Lanes.Components.Grid.Editing]

    render: ->
        <div className="editor row" style={top: @topOffset() - 3}>
            {@renderBody()}
        </div>

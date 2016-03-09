##= require ./EditingMixin

class Lanes.Components.Grid.RowEditor extends Lanes.React.Component

    mixins: [Lanes.Components.Grid.EditingMixin]

    render: ->
        <div className="editor row" style={top: @props.position.top}>
            {@renderEditingBody()}
        </div>

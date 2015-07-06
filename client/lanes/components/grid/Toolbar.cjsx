class Lanes.Components.Grid.Toolbar extends Lanes.React.Component

    propTypes:
        addRecord: React.PropTypes.func

    addButton: ->
        <BS.Button className="navbar-btn" onClick={@props.onAddRecord} bsSize='small'>
            Add Row
        </BS.Button>

    render: ->
        <BS.Navbar className="toolbar">
            {@addButton() if @props.onAddRecord}
        </BS.Navbar>

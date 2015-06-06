class Lanes.Components.Grid.Toolbar extends Lanes.React.Component

    propTypes:
        addRecord: React.PropTypes.func

#        grid: React.PropTypes.instanceOf(Lanes.Components.Grid).isRequired

    # addRow: ->
    #     @props.grid.addRecord()

    addButton: ->
        <BS.Button onClick={@props.addRecord} bsSize='small'>
            Add Row
        </BS.Button>

    render: ->
        <BS.Navbar className="toolbar">
          <BS.ButtonToolbar className="pull-right">
              {@addButton() if @props.addRecord}
          </BS.ButtonToolbar>
        </BS.Navbar>

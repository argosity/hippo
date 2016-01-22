class Lanes.Components.Grid.Toolbar extends Lanes.React.BaseComponent

    propTypes:
        addRecord: React.PropTypes.func
        startEdit: React.PropTypes.func

    onAddRecord: ->
        model = @props.query.results.addBlankRow(0)
        @props.startEdit(0)

    AddButton: ->
        return null unless @props.allowCreate
        <BS.Button className="navbar-btn add-row pull-right"
            onClick={@onAddRecord} bsSize='small'
        >
            <LC.Icon type="plus" />Add Row
        </BS.Button>

    render: ->
        return null if false == @props.commands?.isEditing() or not @props.allowCreate

        props = _.extend {}, @props,
        <Lanes.Components.Grid.Toolbar key="toolbar" {...props} />

        <BS.Navbar className="toolbar">
            <@AddButton />
        </BS.Navbar>

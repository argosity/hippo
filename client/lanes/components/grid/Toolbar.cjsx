class Lanes.Components.Grid.Toolbar extends Lanes.React.BaseComponent

    propTypes:
        addRecord: React.PropTypes.func
        startEdit: React.PropTypes.func
        toolbarChildren: React.PropTypes.oneOfType([
            React.PropTypes.element,
            React.PropTypes.arrayOf(React.PropTypes.element)
        ])

    onAddRecord: ->
        @props.query.results.addBlankRow(0)
        @props.startEdit(0)

    AddButton: ->
        return null unless @props.allowCreate
        <BS.Button className="navbar-btn add-row pull-right"
            onClick={@onAddRecord} bsSize='small'
        >
            <LC.Icon type="plus" />Add Row
        </BS.Button>

    render: ->
        if ( ( false == @props.commands?.isEditing() or not @props.allowCreate ) and not @props.toolbarChildren )
            return null

        props = _.extend {}, @props,
        <Lanes.Components.Grid.Toolbar key="toolbar" {...props} />

        <BS.Navbar className="toolbar">
            {@props.toolbarChildren}
            <@AddButton />
        </BS.Navbar>

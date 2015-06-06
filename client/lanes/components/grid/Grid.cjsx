##= require_self
##= require ./Toolbar
##= require ./Editing
##= require ./RowEditor
##= require ./PopoverEditor

class Lanes.Components.Grid extends Lanes.React.Component

    mixins: [
        Lanes.React.Mixins.MonitorSize
    ]

    dataObjects:
        query: 'props'

    bindDataEvents:
        query: 'change execute'

    setDataState: (newstate) ->
        if newstate.query
            @refs.grid?.reload()

    propTypes:
        query:  React.PropTypes.object.isRequired
        width:  React.PropTypes.number
        height: React.PropTypes.number
        editor: React.PropTypes.object
        allowCreate: React.PropTypes.bool
        onSelectionChange: React.PropTypes.func

    getDefaultProps: ->
        rowHeight: 30

    getInitialState: ->
        width: 800, height: 500
        sortInfo: []
        rowHeight: 30
        fieldIds: @query.fields.pluck('id')
        columns:  @query.fields.map (f, i) ->
            _.extend(
                _.pick(f, 'id', 'title', 'flex', 'visible', 'textAlign')
            , name: "#{i}")

    dataSource: (q) ->
        return @query.results.ensureLoaded({
            start: q.skip || 0, limit: q.pageSize || 100
        }).then (result) =>
            @setState(data: result)
            count: result.total, data: result.rows

    addRecord: ->
        @query.results.addBlankRow()
        @setState(selIndex: 0)

    onSelectionChange: (selectedId, data, index) ->
        newIndex = (if @state.selIndex == index then null else index)
        @setState(selIndex: newIndex)
        @props.onSelectionChange?(
            if newIndex? then @state.data.modelForRow(data) else null
        )

    onColumnResize: (firstCol, firstSize, secondCol, secondSize) ->
        firstCol.width = firstSize
        this.setState({})

    onSortChange: (sortInfo) ->
        @refs.grid.data = _.sorty(sortInfo, @refs.grid.data)
        @setState(sortInfo: sortInfo, selIndex: undefined)

    getSelected: ->
        @refs.grid.data[@state.selIndex] if @state.selIndex? && @refs.grid

    render: ->
        <div className="grid-component">
            {@renderEditor() if @props.editor and @state.selIndex?}
            <Lanes.Vendor.Grid
                ref="grid"
                rowHeight={@props.rowHeight}
                dataSource={@dataSource}
                paginationFactory = {@makeToolBar}
                selected={@getSelected()?.id}
                sortInfo={@state.sortInfo}
                onSortChange={@onSortChange}
                onSelectionChange={@onSelectionChange}
                idProperty='0'
                pagination={true}
                onColumnResize={@onColumnResize}
                paginationToolbarProps = { position: 'top' }
                style={{height: 400}}
                columns={@state.columns}/>
        </div>

    hideEditor: -> @setState(selIndex: null)

    onEditSave: (model) ->
        @state.data.saveModelChanges(model)
        this.hideEditor()

    renderEditor: ->
        editor = if true == @props.editor
            Lanes.Components.Grid.RowEditor
        else
            @props.editor
        React.createElement(@props.editor,
            topOffset  : 100
            model      : @state.data.modelForRow(@getSelected())
            hideEditor : @hideEditor
            onSave     : @onEditSave
            editors    : @props.editors
            columns    : @state.columns
            rowHeight  : @props.rowHeight
            rowIndex   : @state.selIndex
        )

    makeToolBar: (props) ->
        if @props.allowCreate
            props.addRecord = @addRecord
            <Lanes.Components.Grid.Toolbar {...props}/>
        else
            null

##= require_self
##= require ./Toolbar
##= require ./RowEditor
##= require ./PopoverEditor

class Lanes.Components.Grid extends Lanes.React.Component

    mixins: [
        Lanes.React.Mixins.MonitorSize
    ]

    dataObjects:
        query: 'props'

    bindDataEvents:
        query: 'load'

    propTypes:
        query:  React.PropTypes.instanceOf(Lanes.Models.Query).isRequired
        width:  React.PropTypes.number
        height: React.PropTypes.number
        editor: React.PropTypes.oneOfType([
            React.PropTypes.func
            React.PropTypes.bool
        ])
        allowCreate:  React.PropTypes.bool
        expandY:      React.PropTypes.bool
        columEditors: React.PropTypes.object
        onSelectionChange: React.PropTypes.func
        autoLoadQuery: React.PropTypes.bool

    getDefaultProps: ->
        headerHeight: 50, rowHeight: 30, editorProps: {}, autoLoadQuery: true

    getInitialState: ->
        columnWidths: {}, toolbar: !!@props.allowCreate

    componentWillMount: -> @query.results.ensureLoaded() if @props.autoLoadQuery

    renderColumns: ->
        @query.fields.visible.map (f, i) =>
            <Lanes.Vendor.Grid.Column
                dataKey={i}
                columnData={f}
                align={f.textAlign}
                isResizable={true}
                flexGrow={f.flex}
                label={f.title}
                width={@state.columnWidths[i] || 10}
                key={i}
            />

    onRowClick: (ev, index) ->
        newIndex = (if @state.selIndex == index then null else index)
        el = Lanes.u.closestEl(ev.target, 'public_fixedDataTableCell_main')
        @setState(selIndex: newIndex, editingEl: el)
        @props.onSelectionChange?(
            if newIndex? then @query.results.modelAt(newIndex) else null
        )

    headerHeight: ->
        @props.headerHeight + ( if @state.toolbar then @props.headerHeight else 0 )

    onSortChange: (sortInfo) ->
        @refs.grid.data = _.sorty(sortInfo, @refs.grid.data)
        @setState(sortInfo: sortInfo, selIndex: undefined)

    getSelected: ->
        @query.results.modelAt(@state.selIndex) if @state.selIndex?

    rowGetter: (rowIndex) ->
        @query.results.rowAt(rowIndex, visibleOnly:true)

    onColumnResizeEnd: (width, index) ->
        columnWidths = @state.columnWidths || {}
        columnWidths[index] = width
        @setState({columnWidths})

    hideEditor: -> @setState(selIndex: null)

    onEditCancel: (model) ->
        if model.isNew()
            @query.results.removeRow(@state.selIndex)
        this.hideEditor()

    onEditSave: (model) ->
        @query.results.saveModelChanges(model, @state.selIndex)
        this.hideEditor()

    renderToolbar: ->
        return null if not @state.toolbar or false is @props.commands?.isEditing()
        props = _.clone(@props)
        props.onAddRecord = =>
            @query.results.addBlankRow(0)
            @setState(selIndex: 0)
        <Lanes.Components.Grid.Toolbar {...props} />

    renderEditor: ->
        editor = if true == @props.editor
            Lanes.Components.Grid.RowEditor
        else
            @props.editor
        React.createElement(editor, _.extend({
            topOffset  : @headerHeight()
            grid       : this
            query      : @query
            model      : @getSelected().clone()
            onCancel   : @onEditCancel
            onSave     : @onEditSave
            editingEl  : @state.editingEl
            editors    : @props.columEditors
            rowIndex   : @state.selIndex
            rowHeight  : @props.rowHeight
            allowDelete: @props.allowDelete and @props.commands?.isEditing()
        }, @props.editorProps))

    renderLoading: ->
        <div className="grid-component">
            <div className="loading">Loading ...</div>
        </div>

    columnWidths: ->
        width = @width()
        each = width / @query.fields.visible.length
        @query.fields.visible.map( (field, i) =>
            fixed = @state.columnWidths[i] || (each * (field.flex || 1))
        )

    onResize: _.debounce( (size) ->
        @setState({size})
    , 300)

    height:  -> (@state.size?.height || 300) - (if @state.toolbar then 50 else 0)
    width:   -> (@props.width  || @state.size?.width  || 500 )
    canEdit: -> @props.editor and (not @props.commands or @props.commands?.isEditing())

    render: ->
        <LC.ResizeSensor onResize={@onResize}
            className={_.classnames('grid-component', 'flex-row-expand': @props.expandY)} >

            <div className='wrapper'>

                {@renderToolbar()}

                {@renderEditor() if @canEdit() and @state.selIndex?}

                <Lanes.Vendor.Grid
                    ref="grid"
                    rowsCount={@query.results.length}
                    rowGetter={@rowGetter}
                    onRowClick={@onRowClick}
                    onColumnResizeEndCallback={@onColumnResizeEnd}
                    rowHeight={@props.rowHeight}
                    headerHeight={@props.headerHeight}
                    width={@width()}
                    height={@height()}
                >
                    {@renderColumns()}
                </Lanes.Vendor.Grid>

            </div>
        </LC.ResizeSensor>

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

    setDataState: (newstate) ->
        @refs.grid?.reload() if newstate.query

    componentWillReceiveProps: (nextProps) ->
        @refs.grid.reload() if nextProps.query isnt @props.query

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
        headerHeight: 40, rowHeight: 30, editorProps: {}, autoLoadQuery: true

    getInitialState: ->
        toolbar: !!@props.allowCreate

    componentWillMount: -> @query.results.ensureLoaded(0) if @props.autoLoadQuery

    onRowClick: (col, row, index) ->
        selectedIndex = (if @state.selectedIndex == index then null else index)
        selectedModel = if selectedIndex? then @query.results.modelAt(selectedIndex).clone() else null
        set = (attrs = {} ) => @setState(_.extend(attrs, {selectedIndex, selectedModel}))
        if @props.onSelectionChange
            osc = @props.onSelectionChange(selectedModel)
            if _.isPromise(osc)
                @setState(is_loading: true)
                osc.then -> set(is_loading: false)
            else
                set()
        else
            set()

    headerHeight: ->
        @props.headerHeight + ( if @state.toolbar then @props.headerHeight else 0 )

    onSortChange: (sortInfo) ->
        for sortConfig in sortInfo
            sort = @query.fields.at(sortConfig.name).sortBy
            sortConfig.fn = sort if sort

        @setState(sortInfo: sortInfo, selectedIndex: undefined, selectedModel: undefined)

    hideEditor: -> @setState(selectedIndex: null)

    onEditCancel: (model) ->
        if model.isNew()
            @query.results.removeRow(@state.selectedIndex)
        this.hideEditor()

    onEditSave: (model) ->
        @query.results.saveModelChanges(model, @state.selectedIndex)

        this.refs.grid.data[this.state.selectedIndex] =
            @query.results.rowAt( @state.selectedIndex, visibleOnly: true )

        this.hideEditor()

    renderEditor: ->
        editor = if true == @props.editor
            Lanes.Components.Grid.RowEditor
        else
            @props.editor
        React.createElement(editor, _.extend({
            topOffset  : @headerHeight()
            grid       : this
            query      : @query
            model      : @state.selectedModel
            onCancel   : @onEditCancel
            onSave     : @onEditSave
            editors    : @props.columEditors
            rowIndex   : @state.selectedIndex
            rowHeight  : @props.rowHeight
            allowDelete: @props.allowDelete and @props.commands?.isEditing()
        }, @props.editorProps))

    onResize: _.debounce( (size) ->
        @setState(size: {height: size.height, width: size.width})
    , 300)

    height:  -> (@state.size?.height || 300)
    width:   -> (@props.width  || @state.size?.width  || 500 )
    canEdit: -> @props.editor and (not @props.commands or @props.commands?.isEditing())

    computedColumns: ->
        @query.fields.visible.map (f, i) ->
            _.extend( _.pick( f,  'id', 'title', 'flex', 'visible', 'textAlign' ), name: "#{i}" )

    makeToolBar: ->
        return null if not @state.toolbar or false is @props.commands?.isEditing()
        props = _.extend {}, @props,
            position: 'top',
            onAddRecord: =>
                model = @query.results.addBlankRow(0)
                @setState(selectedIndex: 0, selectedModel: model)
        <Lanes.Components.Grid.Toolbar key="toolbar" {...props} />

    dataSource: (q) ->
        @setState(is_loading: true)
        @query.results.allRows(page: q.page, visibleOnly: true).then (rows) =>
            @setState(is_loading: false)
            count: rows.length, data: rows

    render: ->
        <LC.ResizeSensor onResize={@onResize}
            className={_.classnames('grid-component', 'flex-row-expand': @props.expandY)} >

            <div className='wrapper'>

                {@renderEditor() if @canEdit() and @state.selectedIndex?}

                <Lanes.Vendor.Grid
                    ref="grid"
                    emptyText={"No #{@query.title} found"}
                    rowHeight={@props.rowHeight}
                    dataSource={@dataSource}
                    paginationFactory = {@makeToolBar}
                    selected={@state.selectedModel?.id}
                    sortInfo={@state.sortInfo}
                    onSortChange={@onSortChange}
                    onSelectionChange={@onRowClick}
                    idProperty='0'
                    loading={@state.is_loading}
                    pagination={true}
                    onColumnResize={@onColumnResize}
                    paginationToolbarProps = { position: 'top' }
                    style={{height: @height()}}
                    columns={@computedColumns()} />

            </div>
        </LC.ResizeSensor>

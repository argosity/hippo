##= require_self
##= require ./Toolbar
##= require ./RowEditor
##= require ./PopoverEditor
##= require ./CellStyles
##= require ./Header
##= require ./Body
##= require ./Selections

class Lanes.Components.Grid extends Lanes.React.Component

    mixins: [
        Lanes.React.Mixins.MonitorSize
    ]

    dataObjects:
        query: 'props'

    bindDataEvents:
        query: 'load change'

    getInitialState: ->
        {}

    componentWillReceiveProps: (nextProps) ->
        if nextProps.autoLoadQuery and nextProps.query isnt @props.query
            nextProps.query.ensureLoaded()

    propTypes:
        query:  React.PropTypes.instanceOf(Lanes.Models.Query).isRequired
        width:  React.PropTypes.number
        height: React.PropTypes.number
        editor: React.PropTypes.oneOfType([
            React.PropTypes.func
            React.PropTypes.bool
        ])
        allowCreate:  React.PropTypes.bool
        columEditors: React.PropTypes.object
        onSelectionChange: React.PropTypes.func
        autoLoadQuery: React.PropTypes.bool

    getDefaultProps: ->
        editorProps: {}, autoLoadQuery: true

    componentWillMount: ->
        @query.ensureLoaded() if @props.autoLoadQuery

    onSortChange: (sortInfo) ->
        for sortConfig in sortInfo
            sort = @query.fields.at(sortConfig.name).sortBy
            sortConfig.fn = sort if sort

        @setState(sortInfo: sortInfo, selectedIndex: undefined, selectedModel: undefined)

    startEdit: (editingRowIndex = 0) ->
        @setState({editingRowIndex})

    render: ->
        cellStyles = new Lanes.Components.Grid.CellStyles(@query.fields)

        <div className='grid-component'>
            <Lanes.Components.Grid.Toolbar {...@props} startEdit={@startEdit} />
            <Lanes.Components.Grid.Header  {...@props} cellStyles={cellStyles} />
            <Lanes.Components.Grid.Body
                {...@props}
                editingRowIndex={@state.editingRowIndex}
                cellStyles={cellStyles}
                onRowClick={@onRowClick}
            />
        </div>

##= require_self
##= require ./Toolbar
##= require ./RowEditor
##= require ./PopOverMixin
##= require ./PopoverEditor
##= require ./CellStyles
##= require ./Header
##= require ./Body
##= require ./Selections

class Lanes.Components.Grid extends Lanes.React.Component

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
        onColumnClick: React.PropTypes.func
        onSelectionChange: React.PropTypes.func
        autoLoadQuery: React.PropTypes.bool
        renderCompleteResults: React.PropTypes.bool
        toolbarChildren: React.PropTypes.oneOfType([
            React.PropTypes.element,
            React.PropTypes.arrayOf(React.PropTypes.element)
        ])

    mixins: [
        Lanes.React.Mixins.MonitorSize
    ]

    modelBindings:
        query: 'props'

    bindEvents:
        query: 'load change sort'

    componentWillReceiveProps: (nextProps) ->
        if nextProps.autoLoadQuery and nextProps.query isnt @props.query
            nextProps.query.ensureLoaded()

    componentWillMount: ->
        @query.ensureLoaded() if @props.autoLoadQuery

    getInitialState: ->
        {}

    getDefaultProps: ->
        editorProps: {}, autoLoadQuery: true

    onSortChange: (sortInfo) ->
        for sortConfig in sortInfo
            sort = @query.fields.at(sortConfig.name).sortBy
            sortConfig.fn = sort if sort

        @setState(sortInfo: sortInfo, selectedIndex: undefined, selectedModel: undefined)

    startEdit: (index, options = {}) ->
        editing = _.extend({}, options, {
            index: index,
            model: options.model or @props.query.results.modelAt(index)
            position: options.position || @refs.body.getDefaultEditingPosition()
        })
        set = (attrs = {}) =>
            if @props.editor and false isnt @props.commands?.isEditing()
                @setState( _.extend({}, attrs, {editing}) )
        if @props.onSelectionChange
            osc = @props.onSelectionChange(editing.model, editing.index)
            if _.isPromise(osc)
                @setState(is_loading: true)
                osc.then -> set(is_loading: false)
            else
                set()
        else
            set()

    cancelEdit: ->
        if @state.editing?.model.isNew()
            @props.query.results.removeRow(@state.editing.index)
        @setState(editing: null)

    saveEdit: ->
        @setState(editing: null)

    onRowClick: (model, selectedIndex, position) ->
        @startEdit(selectedIndex, {position, model})

    render: ->
        cellStyles = new Lanes.Components.Grid.CellStyles(@query.fields)

        <div className='grid-component'>
            <Lanes.Components.Grid.Toolbar {...@props} startEdit={@startEdit} />
            <Lanes.Components.Grid.Header  {...@props} cellStyles={cellStyles} />
            <Lanes.Components.Grid.Body
                {...@props}
                ref='body'
                editing={@state.editing}
                onEditSave={@saveEdit}
                onEditCancel={@cancelEdit}
                isLoading={@state.isLoading}
                cellStyles={cellStyles}
                onRowClick={@onRowClick if @props.editor or @props.onSelectionChange}
            />
        </div>

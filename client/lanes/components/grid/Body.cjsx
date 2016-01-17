class Lanes.Components.Grid.Body extends Lanes.React.BaseComponent

    propTypes:
        query:      React.PropTypes.instanceOf(Lanes.Models.Query).isRequired
        cellStyles: React.PropTypes.object.isRequired

    fieldConvertors:
        bigdec: (v) -> v.toFixed(2)

    getInitialState: ->
        selectedModel: false

    onEditCancel: (model) ->
        if model.isNew()
            @props.query.results.removeRow(@state.selectedIndex)
        this.hideEditor()

    hideEditor: ->
        # BUG? Without the defer, render is called with old state
        _.defer => @setState(selectedIndex: null, selectedModel: null)

    onEditSave: (model, isDeleted = false) ->
        if (isDeleted)
            @props.query.results.removeRow(@state.selectedIndex)
        else
            @props.query.results.saveModelChanges(model, @state.selectedIndex)
        this.hideEditor()

    componentWillReceiveProps: (nextProps) ->
        if nextProps.editingRowIndex?
            @setState(
                selectedIndex: nextProps.editingRowIndex
                selectedModel: @props.query.results.modelAt(nextProps.editingRowIndex).clone()
            )
    onRowClick: (ev, row, index) ->
        editTopOffset = this.refs.list.getScroll() + (
            ev.target.getBoundingClientRect().top - _.dom(this).el.getBoundingClientRect().top
        )
        selectedIndex = (if @state.selectedIndex == index then null else index)
        selectedModel = if selectedIndex? then @props.query.results.modelAt(selectedIndex).clone() else null
        set = (attrs = {}) =>
            @setState(_.extend(attrs, {selectedIndex, selectedModel, editTopOffset})) unless false is @props.commands?.isEditing()

        if @props.onSelectionChange
            osc = @props.onSelectionChange(selectedModel, selectedIndex)
            if _.isPromise(osc)
                @setState(is_loading: true)
                osc.then -> set(is_loading: false)
            else
                set()
        else
            set()

    convertValue: (value, field) ->
        if @fieldConvertors[field.type] then @fieldConvertors[field.type](value) else value

    renderColumn: (rowNum, index, field, results, row) ->
        value = results.valueForField(rowNum, field)

        onColClick = if field.onColumnClick
            _.partial(field.onColumnClick, _,
                {value, field, index, rowNum, row, query: @props.query }
            )
        else
            null

        value = if field.format
            field.format(value, row, @props.query)
        else
            @convertValue(value, field)

        value = React.createElement( field.render,
            {value: value, query: @props.query, row, index: rowNum}
        ) if field.render

        <div key={field.id}
            onClick={onColClick}
            {...@props.cellStyles.props[index]}
        >
            {value}
        </div>


    renderRow: (rowNum, ref) ->
        fields = []
        results = @props.query.results
        row = results.rowRepresentation(rowNum)
        for field, index in @props.query.fields.models when field.visible
            fields.push @renderColumn(rowNum, index, field, results, row)

        onClick = _.partial(@onRowClick, _, row, rowNum)
        <div key={rowNum} ref={ref} className="r" onClick={onClick} >
            {fields}
        </div>

    renderEditor: ->
        editor = if true == @props.editor
            Lanes.Components.Grid.RowEditor
        else
            @props.editor

        React.createElement(editor, _.extend({
            topOffset  : @state.editTopOffset
            query      : @props.query
            model      : @state.selectedModel
            onCancel   : @onEditCancel
            onSave     : @onEditSave
            cellStyles : @props.cellStyles
            editors    : @props.columEditors
            rowIndex   : @state.selectedIndex
            rowHeight  : @props.rowHeight
            allowDelete: @props.allowDelete and @props.commands?.isEditing()
        }, @props.editorProps))

    isEditing: ->
        @props.editor and @state.selectedModel and @state.selectedIndex?

    render: ->
        <div className={_.classnames('grid-body', 'is-editing': @isEditing())}>
            {@renderEditor() if @isEditing()}
            <Lanes.Vendor.List
                useTranslate3d
                isEditing={!!@state.selectedModel}
                itemRenderer={@renderRow}
                length={@props.query.results.length}
                type='variable'
                ref="list"
            />
        </div>

class Lanes.Components.Grid.Editor extends Lanes.React.BaseComponent

    propTypes:
        onCancel: React.PropTypes.func.isRequired

    getInitialState: ->
        selectedModel: false

    onEditCancel: (model) ->
        @props.onCancel(model)

    onEditSave: (model, isDeleted = false) ->
        if (isDeleted)
            @props.query.results.removeRow(@state.selectedIndex)
        else
            @props.query.results.saveModelChanges(model, @state.selectedIndex)

        @props.onSave()

    componentWillReceiveProps: (nextProps) ->
        if nextProps.editingRowIndex?
            @setState(
                selectedIndex: nextProps.editingRowIndex
                selectedModel: @props.query.results.modelAt(nextProps.editingRowIndex)?.clone()
            )

    render: ->
        return null unless @props.editing

        Editor = if true == @props.editor
            Lanes.Components.Grid.RowEditor
        else
            @props.editor
        <Editor
            {...@props.editing}
            {...@props.editorProps}
            query       = {@props.query}
            model       = {@props.editing.model}
            onCancel    = {@onEditCancel}
            onSave      = {@onEditSave}
            cellStyles  = {@props.cellStyles}
            editors     = {@props.columEditors}
            rowIndex    = {@props.editing.index}
            rowHeight   = {@props.rowHeight}
            allowDelete = {@props.allowDelete and @props.commands?.isEditing()}
        />

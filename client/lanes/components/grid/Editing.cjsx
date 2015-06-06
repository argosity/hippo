Lanes.Components.Grid ||= {}
Lanes.Components.Grid.Editing = {

    propTypes:
        topOffset: React.PropTypes.number.isRequired
        rowIndex:  React.PropTypes.number.isRequired
        rowHeight: React.PropTypes.number.isRequired
        columns:   React.PropTypes.arrayOf(React.PropTypes.object).isRequired
        onSave:    React.PropTypes.func.isRequired
        model:     Lanes.PropTypes.State.isRequired
        editors:   React.PropTypes.object
        hideEditor:  React.PropTypes.func.isRequired

    topOffset: ->
        @props.topOffset + (@props.rowIndex * @props.rowHeight)

    renderControls: ->
        <div className="controls">
            <div className="buttons">
                <button type="button" className="btn cancel" onClick={@props.hideEditor}>
                    <i className="icon-cancel-circle">Cancel</i>
                </button>
                <button type="button" className="btn save" onClick={@saveRecord}>
                    <i className="icon-save">Save</i>
                </button>
            </div>
        </div>

    renderField: (column) ->
        return null unless column.visible
        if @props.editors[column.id]
            @props.editors[column.id]
        else
            <LC.TextField key={column.id}
                label={column.title}
                model={@model}
                id={column.id}/>

    saveRecord: ->
        @props.model.save().then (model) =>
            @props.onSave(model)
}

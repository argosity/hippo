class Lanes.Components.RecordFinder extends Lanes.React.Component

    propTypes:
        query:    Lanes.PropTypes.State.isRequired
        model:    Lanes.PropTypes.State.isRequired
        commands: React.PropTypes.object.isRequired


    contextTypes:
        uistate: Lanes.PropTypes.State.isRequired

    showFinder: ->
        @context.uistate.modalDialog = =>
            React.createElement LC.RecordFinder.Dialog,
                query: @props.query
                onRecordSelect: @props.commands.setModel

    loadCurrentSelection: ->
        @props.query.loadSingle(@refs.input.getValue()).then (model) =>
            @props.commands.setModel(model)

    onKeyPress: (ev) ->
        if "Enter" == ev.key
            ev.stopPropagation()
            this.loadCurrentSelection()
        null

    render: ->
        findIcon = <button className="btn btn-primary icon icon-search icon-lg" onClick={@showFinder}/>
        <LC.Input
            ref="input"
            {...@props}
            groupClassName="record-finder"
            editOnly writable
            name={@props.query.initialField.id}
            onKeyPress={@onKeyPress}
            model={@props.model}
            buttonAfter={findIcon} />

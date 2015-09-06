class Lanes.Components.RecordFinder extends Lanes.React.Component

    propTypes:
        query:    Lanes.PropTypes.State.isRequired
        model:    Lanes.PropTypes.State.isRequired
        commands: React.PropTypes.object.isRequired


    contextTypes:
        viewport: Lanes.PropTypes.State.isRequired

    showFinder: ->
        body = Lanes.u.withReactContext @context, =>
            <LC.RecordFinder.Dialog query={@props.query} onRecordSelect={@props.commands.setModel} />

        @context.viewport.displayModal(
            body: body
            title: "Find #{@props.query.title}"
            buttons: [{title: 'Cancel'}]
        ).then(Lanes.emptyFn, Lanes.emptyFn)

    loadCurrentSelection: ->
        value = @props.model[@props.query.initialField.id]
        @props.query.loadSingle(value).then (model) =>
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

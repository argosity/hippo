class Lanes.Components.RecordFinder extends Lanes.React.Component

    propTypes:
        query:    Lanes.PropTypes.State.isRequired
        model:    Lanes.PropTypes.State.isRequired
        commands: React.PropTypes.object
        onModelSet: React.PropTypes.func

    contextTypes:
        viewport: Lanes.PropTypes.State.isRequired

    mixins: [
        Lanes.Components.Form.FieldMixin
    ]

    showFinder: ->
        @context.viewport.displayModal(
            title: "Find #{@props.query.title}"
            buttons: [{title: 'Cancel'}]
            body: =>
                <LC.RecordFinder.Dialog query={@props.query} onRecordSelect={@setModel} />
        ).then(Lanes.emptyFn, Lanes.emptyFn)

    setModel: (model) ->
        @props.commands?.setModel(model)
        @props.onModelSet?(model)

    loadCurrentSelection: ->
        value = @props.model[@props.query.initialField.id]
        @props.query.loadSingle(value).then (model) =>
            @setModel(model)

    onKeyPress: (ev) ->
        if "Enter" == ev.key
            ev.stopPropagation()
            this.loadCurrentSelection()
        null

    renderEdit: ->
        findIcon = <button className="btn btn-primary icon icon-search icon-lg"
            onClick={@showFinder}/>
        <LC.Input
            ref="input"
            {...@props}
            groupClassName="record-finder"
            editOnly writable
            name={@props.query.initialField.id}
            onKeyPress={@onKeyPress}
            model={@props.model}
            buttonAfter={findIcon} />

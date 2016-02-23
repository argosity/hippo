class Lanes.Components.RecordFinder extends Lanes.React.Component

    propTypes:
        query:       Lanes.PropTypes.State.isRequired
        model:       Lanes.PropTypes.State
        parentModel: Lanes.PropTypes.State
        commands:    React.PropTypes.object
        onModelSet:  React.PropTypes.func

    contextTypes:
        viewport: Lanes.PropTypes.State.isRequired

    modelForAccess: ->
        if @props.parentModel
            @props.parentModel[@props.associationName]
        else
            @props.model

    showFinder: ->
        @props.query.reset()
        @context.viewport.displayModal(
            title: "Find #{@props.query.title}"
            buttons: [{title: 'Cancel'}]
            autoHide: true
            body: =>
                <LC.RecordFinder.Dialog query={@props.query} onRecordSelect={@setModel} />
        )

    setModel: (model) ->
        if @props.parentModel
            @props.parentModel.set(@props.associationName, model)
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

    getValue: ->
        if @props.parentModel
            @props.parentModel[@props.associationName][@props.name]
        else
            @props.model[@props.name]


    render: ->
        findIcon = <button className="btn btn-primary icon icon-search icon-lg" onClick={@showFinder}/>

        label =
            <LC.ControlLabel titleOnly {...@props} />

        <LC.Input
            ref="input"
            groupClassName="record-finder"
            editOnly writable
            name={@props.query.initialField.id}
            onKeyPress={@onKeyPress}
            {...@props}
            label={label}
            model={@modelForAccess()}
            getValue={@getValue}
            buttonAfter={findIcon} />

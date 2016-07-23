class Lanes.Components.RecordFinder extends Lanes.React.Component

    listenNetworkEvents: true

    propTypes:
        query:       Lanes.PropTypes.State.isRequired
        model:       Lanes.PropTypes.State
        parentModel: Lanes.PropTypes.State
        commands:    React.PropTypes.object
        onModelSet:  React.PropTypes.func

    mixins: [
        Lanes.Components.Form.InputFieldMixin
    ]

    contextTypes:
        viewport: Lanes.PropTypes.State.isRequired

    modelBindings: ->
        query: 'props'

    modelForAccess: ->
        if @props.parentModel
            @props.parentModel[@props.associationName]
        else
            @props.model

    showFinder: ->
        query = @props.query.clone()
        query.autoRetrieve = true
        @context.viewport.displayModal(
            title: "Find #{@props.query.title}"
            buttons: [{title: 'Cancel'}]
            autoHide: true
            body: =>
                <LC.RecordFinder.Dialog query={query} onRecordSelect={@setModel} />
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

    getValue: (ev) ->
        value = if @props.parentModel
            @props.parentModel[@props.associationName]?[@props.name]
        else
            @props.model[@props.name]
        value or ''

    renderInputField: (props, handlers) ->
        model = @props.parentModel or @props.model
        <BS.InputGroup className="record-finder">
            <BS.FormControl
                {...props} {...handlers}
                onChange={@fieldMixinSetValue}
                value={@getValue()}
                onKeyPress={@onKeyPress}
            />

            <BS.InputGroup.Button>
                <button className='btn btn-primary' onClick={@showFinder}>
                    <LC.Icon lg
                        type={if @state.isRequesting then 'spinner' else 'search'}
                    />
                </button>
            </BS.InputGroup.Button>
        </BS.InputGroup>

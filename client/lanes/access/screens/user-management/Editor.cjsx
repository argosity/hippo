class Lanes.Access.Screens.UserManagement.Editor extends Lanes.React.Component

    mixins: [Lanes.Components.Grid.PopoverMixin]

    getInitialState: ->
        link: LC.Helpers.modelLinkFields(@props.model)
        recordName: @props.model.name || @props.model.title

    renderBody: ->
        <form>
            {@renderFields()}
            <div className="field">
                <label>Password</label>
                <input {...@state.link('password')} type="password" />
            </div>
            {@renderControls()}
        </form>

    render: ->
        @renderPopover()

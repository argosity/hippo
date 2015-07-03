class Lanes.Access.Screens.UserManagement.Editor extends Lanes.React.Component

    mixins: [Lanes.Components.Grid.Editing]
    getInitialState: ->
        link: LC.Helpers.modelLinkFields(@props.model)
    render: ->

        <div className="editor po">
            <BS.Popover
                placement    ='right'
                positionLeft ={200}
                positionTop={@topOffset() - 100}
                arrowOffsetTop={100 + @props.rowHeight / 2}
                title        ="Edit #{@model.name || 'Record'}"
            >
                <form>
                    {@renderFields()}
                    <div className="field">
                        <label>Password</label>
                        <input {...@state.link('password')} type="password" />
                    </div>
                    {@renderControls()}
                </form>
            </BS.Popover>
        </div>

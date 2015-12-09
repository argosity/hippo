class Lanes.Access.Screens.UserPreferences extends Lanes.React.Screen

    dataObjects:
        user: -> Lanes.current_user

    getInitialState: ->
        commands: new Lanes.Screens.Commands(this, modelName: 'user')

    setScreens: (model, screens) ->
        @user.options = _.extend({}, @user.options, {initial_screens: _.pluck(screens, 'id')})

    getScreens: ->
        _.map(@user.options?.initial_screens || [], (id) ->
            screen = Lanes.Screens.Definitions.all.get(id)
            {id, label: screen.label}
        )

    render: ->
        <LC.ScreenWrapper identifier="user-preferences">
            <Lanes.Screens.CommonComponents commands={@state.commands} />
            <BS.Row>
                <LC.SelectField xs=12 multi
                    fetchWhenOpen={false}
                    label='Initial Screens'
                    labelField='label'
                    model={@user} name='options'
                    collection={Lanes.Screens.Definitions.all}
                    setSelection={@setScreens}
                    getSelection={@getScreens}
                />
            </BS.Row>
        </LC.ScreenWrapper>

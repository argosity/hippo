class Lanes.Access.Screens.UserManagement extends Lanes.React.Screen

    getInitialState: ->
        fields = [
            {id:'id', visible: false}
            'login', 'name', 'email', {id:'role_names', title:'Role Names'}
        ]
        query: new Lanes.Models.Query(fields: fields, src: Lanes.Models.User)

    rolesForUser: (user) ->
        _.map user.role_names, (rn) -> {id: rn, name: _.titleize(rn) }

    setRolesForUser: (roles, options) ->
        options.model.role_names = _.pluck(roles, 'id')

    editors: (props) ->
        role_names: ({model}) =>
            <LC.SelectField
                id="role_names"
                key="row-select"
                queryModel={Lanes.Models.User}
                editOnly multiSelect writable unstyled
                model={model}
                labelField='name'
                getSelection={@rolesForUser}
                setSelection={@setRolesForUser}
                choices={Lanes.Models.Role.all.models}
                fetchWhenOpen={false}
                name="role_names"
            />

    render: ->
        <LC.ScreenWrapper identifier="user-management" flexVertical>
            <h1>Users Management</h1>
            <LC.Grid
                editorProps={height: 400, syncImmediatly: true}
                query={@state.query}
                allowCreate
                editor={Lanes.Access.Screens.UserManagement.Editor}
                columEditors={@editors()}
                ref="grid"/>
        </LC.ScreenWrapper>

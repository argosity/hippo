class Lanes.Access.Screens.UserManagement extends Lanes.React.Screen

    getInitialState: ->
        fields = [
            {id:'id', visible: false}
            'login', 'name', 'email', {id:'role_names', title:'Role Names'}
        ]
        query: new Lanes.Models.Query({
            fields: fields, src: Lanes.Models.User
        })

    rolesForUser: (user) ->
        {value: user.role_names, roles: _.map(user.role_names, _.field2title)}

    setRolesForUser: (model, roles) ->
        model.role_names = _.pluck(roles, 'id')

    editors: (props) ->
        role_names: ({model}) =>
            <LC.SelectField
                id="role_names"
                key="row-select"
                editOnly multi writable unstyled
                model={model}
                name="roles"
                getSelection={@rolesForUser}
                setSelection={@setRolesForUser}
                collection={Lanes.Models.Role.all}
                name="role_names"
            />

    render: ->
        <div>
            <h1>Users Management</h1>
            <LC.Grid
                query={@state.query}
                allowCreate
                editor={Lanes.Access.Screens.UserManagement.Editor}
                columEditors={@editors()}
                ref="grid"/>
        </div>

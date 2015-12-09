class Lanes.Access.Screens.UserManagement extends Lanes.React.Screen

    getInitialState: ->
        fields = [
            {id:'id', visible: false}
            'login', 'name', 'email', {id:'role_names', title:'Role Names'}
        ]
        query: new Lanes.Models.Query(fields: fields, src: Lanes.Models.User)

    rolesForUser: (user) ->
        _.map user.role_names, (rn) -> {id: rn, label: _.field2title(rn) }

    setRolesForUser: (model, roles) ->
        model.role_names = _.pluck(roles, 'id')

    editors: (props) ->
        role_names: ({model}) =>
            <LC.SelectField
                id="role_names"
                key="row-select"
                editOnly multi writable unstyled
                model={model}
                labelField='name'
                getSelection={@rolesForUser}
                setSelection={@setRolesForUser}
                collection={Lanes.Models.Role.all}
                fetchWhenOpen={false}
                name="role_names"
            />

    render: ->
        <LC.ScreenWrapper identifier="user-management">
            <h1>Users Management</h1>
            <LC.Grid
                editorProps={{syncImmediatly: true}}
                query={@state.query}
                allowCreate
                editor={Lanes.Access.Screens.UserManagement.Editor}
                columEditors={@editors()}
                ref="grid"/>
        </LC.ScreenWrapper>

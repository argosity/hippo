class Lanes.Screens.UserManagement extends Lanes.View.Screen

    templateName: 'user-management/user-management'

    subviews:
        grid:
            component: 'Grid'
            options: 'gridOptions'

    gridOptions: ->
        {
            record_query: new Lanes.Data.Query({
                collection_class: Lanes.Data.User.Collection,
                fields: [ 'login', 'name', 'email', 'role_names' ]
            }),
            editor_config: {
                foo: 1
            }
            editing_controller: Lanes.Screens.UserEditScreen
            selectionMode: 'single',
            edit_records: true
            add_records: true
            delete_records: true
        }

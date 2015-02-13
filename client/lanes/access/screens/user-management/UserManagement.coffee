class Lanes.Access.Screens.UserManagement extends Lanes.Screens.Base

    templateName: 'user-management/screen'
    templatePrefix: 'lanes/access/screens'
    FILE: FILE

    subviews:
        grid:
            component: 'Grid'
            options: 'gridOptions'

    gridOptions: ->
        {
            recordQuery: new Lanes.Models.Query({
                modelClass: Lanes.Models.User,
                fields: [ 'login', 'name', 'email', 'role_names' ]
            }),
            editorConfig: {}
            editRecords: true
            editingController: Lanes.Access.Screens.UserManagement.GridUserEditor
            selectionMode: 'single',
            addRecords: true
            deleteRecords: true
        }

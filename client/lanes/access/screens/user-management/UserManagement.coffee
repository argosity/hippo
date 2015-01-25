class Lanes.Access.Screens.UserManagement extends Lanes.Screens.Base

    templateName: 'user-management/screen'
    templatePrefix: 'lanes/access/screens/'
    FILE: FILE

    subviews:
        grid:
            component: 'Grid'
            options: 'gridOptions'

    gridOptions: ->
        {
            recordQuery: new Lanes.Models.Query({
                collection_class: Lanes.Models.UserCollection,
                fields: [ 'login', 'name', 'email', 'role_names' ]
            }),
            editorConfig: {}
            editingController: Lanes.Access.Screens.UserManagement.GridUserEditor
            selectionMode: 'single',
            editRecords: true
            addRecords: true
            deleteRecords: true
        }

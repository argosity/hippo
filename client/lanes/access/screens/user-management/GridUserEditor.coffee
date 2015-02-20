class Lanes.Access.Screens.UserManagement.GridUserEditor extends Lanes.Components.Grid.PopOverEditor

    writeTemplateName: 'user-management/grid-popover-editor'
    templatePrefix: 'lanes/access/screens'
    useFormBindings: true
    writeTemplateData: ->
        { columns: _.reject(this.grid.columnDefinitions,(f)-> f.field=='role_names') }

    subviews:
        roles:
            component: 'SelectField'
            model: 'model'
            options: 'roleOptions'

    roleOptions: ->
        {
            field_name: 'role_names'
            multiple: true, choices: this.model.allRoles
            mappings:{ title: 'name', selected: 'member' }
        }

    persistFields: ->
        @model.set({
            role_names: _.pluck(this.$('select option:selected'), 'value'),
            password:  this.$('input[name=password]').val()
        })

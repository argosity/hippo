class Lanes.Screens.UserEditScreen extends Lanes.Component.Grid.PopOverEditor

    templateName: 'user-management/grid-popover-editor'
    templateData: ->
        { columns: _.reject(this.grid.column_definitions,(f)-> f.field=='role_names') }

    subviews:
        roles:
            component: 'SelectField'
            model: 'model'
            options: 'roleOptions'

    roleOptions: ->
        { multiple: true, data: this.model.allRoles, mappings:{ title: 'name', selected: 'member' } }

    persistFields: ->
        super
        @model.set({
            role_names: _.pluck(this.$('select option:selected'), 'value'),
            password:  this.$('input[name=password]').val()
        })

class Lanes.Access.Screens.UserManagement.GridUserEditor extends Lanes.Components.Grid.PopOverEditor

    writeTemplateName: 'user-management/grid-popover-editor'
    templatePrefix: 'lanes/access/screens'

    writeTemplateData: ->
        { columns: _.reject(this.grid.columnDefinitions,(f)-> f.field=='role_names') }

    subviews:
        roles:
            component: 'SelectField'
            model: 'model'
            options: 'roleOptions'

    roleOptions: ->
        { multiple: true, data: this.model.allRoles, mappings:{ title: 'name', selected: 'member' } }

    constructor: (options={})->
        super( _.extend(options,{formBindings: true}) )

    persistFields: ->
        @model.set({
            role_names: _.pluck(this.$('select option:selected'), 'value'),
            password:  this.$('input[name=password]').val()
        })

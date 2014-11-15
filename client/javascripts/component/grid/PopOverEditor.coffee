class Lanes.Component.Grid.PopOverEditor extends Lanes.Component.Grid.Editor

    templateName: 'grid/popover-editor'
    templateData: ->
        { columns: this.grid.column_definitions }

    session:
        view: 'object'
        title: 'string'

    move: (row,ev)->
        super
        if @popover
            @popover.destroy()
        @popover = new Lanes.Component.PopOver({
                parent: this
                className: 'grid-popover-editor'
                target: Lanes.$(ev.target)
                title: this.title || this.calculated_title()
                content: this.el
                autoShow: true
            })

    calculated_title: ->
        (if this.model.isNew() then "Create: " else "Edit: ") + this.model.constructor.name

    cancelEditing: ->
        @popover.destroy()
        super

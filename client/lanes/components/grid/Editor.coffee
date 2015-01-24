class Lanes.Components.Grid.Editor extends Lanes.Components.Base

    session:
        grid: 'object' # n.b. - not 'state'.  Doing so causes stack overflow since grid also has a 'editor' session var

    domEvents:
        'click .save':   'saveChanges'
        'click .cancel': 'cancelEditing'

    ui:
        form: 'form'

    constructor: (config)->
        super
        this.grid = this.parent

    move: (row)->
        if @row
            this.$el.trigger('cancel-edit',@row)
        @row=row
        @model = this.grid.modelForRow(@row)
        this.render() unless this.rendered
        this.grid.$('.dataTables_scrollBody').append(this.el)
        this.updateFields()

    updateFields: ->
        for input, index in this.$('input')
            if definition = this.getColumn(input.name)
                Lanes.dom.setAttribute(input, 'value', this.model.get(definition.field) )
        this.$('input').first().focus()

    persistFields: ->
        for input, index in this.$('input')
            if definition = this.getColumn(input.name)
                @model.set( definition.field, Lanes.dom.getAttribute(input,'value') )

    getColumn: (name)->
        _.findWhere(this.grid.columnDefinitions, { field: name })

    saveChanges: ->
        this.persistFields()
        @model.save().then => @updateGridRow()

    updateGridRow: ->
        this.$el.trigger('row-updated', @row)
        @grid.updateRow(@row,@model)
        this.cancelEditing()

    cancelEditing: ->
        this.$el.trigger('cancel-edit',@row)
        this.detach()
        this.model = null

    deleteCurrent: ->
        @model.destroy().then =>
            @grid.removeRow(@row)
            @cancelEditing()

    fields: ->
        _.map(this.ui.form.children(), (input,index)->
            { index: index, input: Lanes.$(input), column: this.grid.columnDefinitions[index] }
        ,this)

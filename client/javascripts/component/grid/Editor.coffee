class Lanes.Component.Grid.Editor extends Lanes.Component.Base

    session:
        grid: 'object' # n.b. - not 'state'.  Doing so causes stack overflow since grid also has a 'editor' session var

    events:
        'click .save':   'saveChanges'
        'click .cancel': 'cancelEditing'

    constructor: (config)->
        super
        this.grid = this.parent

    move: (row)->
        if @row
            @grid.fireEvent('cancel-edit',@row)
        @row=row
        @model = this.grid.modelForRow(@row)
        this.render() unless this.rendered
        this.grid.$('.dataTables_scrollBody').append(this.el)
        this.updateFields()

    render: ->
        super
        this.cacheJqElements({
            form: 'form'
        })

    updateFields: ->
        for input, index in this.$('input')
            if definition = this.getColumn(input.name)
                _.dom.setAttribute(input, 'value', this.model.get(definition.field) )
        this.$('input').first().focus()

    persistFields: ->
        for input, index in this.$('input')
            if definition = this.getColumn(input.name)
                @model.set( definition.field, _.dom.getAttribute(input,'value') )

    getColumn: (name)->
        _.findWhere(this.grid.column_definitions, { field: name })

    saveChanges: ->
        this.persistFields()
        @model.save().then => @updateGridRow()

    updateGridRow: ->
        @grid.fireEvent('row-updated', @row)
        @grid.updateRow(@row,@model)
        this.cancelEditing()

    cancelEditing: ->
        @grid.fireEvent('cancel-edit', @row)
        this.detach()
        this.model = null

    deleteCurrent: ->
        @model.destroy().then =>
            @grid.removeRow(@row)
            @cancelEditing()

    fields: ->
        _.map(this.form.children(), (input,index)->
            { index: index, input: Lanes.$(input), column: this.grid.column_definitions[index] }
        ,this)

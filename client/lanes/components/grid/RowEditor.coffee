class Lanes.Components.Grid.RowEditor extends Lanes.Components.Grid.Editor

    template: 'grid/row-editor'

    move: (row)->
        super
        pos = this.row.position()
        this.$el.css({
            left: pos.left, top: pos.top, width: this.row.width()
        })
        this.$('form').css({
            height: this.row.height()
        })
        inputs = this.form.children()
        for input, index in inputs
            column = Lanes.$(this.row[0].cells[index])
            definition = this.grid.columnDefinitions[index]
            Lanes.$(input)
                .width(column.width())
                .css("left", column.position().left)
                .val(this.model.get(definition.field))
        this.form.find('.edit').first().focus()



    render: ->
        super
        for cell in this.row[0].cells
            this.form.append('<input class="edit">')
        this

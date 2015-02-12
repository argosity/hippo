# ModelsTables class modifications
_.extend( Lanes.$.fn.dataTableExt.oStdClasses,{
    sTable: "table table-striped"
    sWrapper: "dataTables_wrapper form-inline"
    sFilterInput: "form-control input-sm"
    sLengthSelect: "form-control input-sm"
})


class Lanes.Components.Grid extends Lanes.Components.Base
    FILE: FILE

    domEvents:
        'click button.refresh': 'reload'
        'click button.delete':  'deleteRow'
        'click button.create':  'addRow'
        'click tr': 'onRowClick'
        'cancel-edit': 'onCancelEdit'
        'order.dt table': 'onSort'

    writeTemplateName: 'template'

    writeTemplateData: ->
        data = { grid: this, buttons: ['refresh'] }
        data['buttons'].push('create') if @addRecords
        data['buttons'].push('delete') if @deleteRecords
        data

    derived:
        columnDefinitions:
            deps:['recordRuery'], fn: ->
                @recordQuery.fields.map(this._makeField, this)

        modelClass:
             deps:['recordQuery'], fn:->
                 @recordQuery?.modelClass

        singleSelectMode:
             deps:['selectionMode'], fn:-> @selectionMode == 'single'

    session:
        editRecords:   ['boolean',true,false]
        addRecords:    ['boolean',true,false]
        deleteRecords: ['boolean',true,false]
        createRecordFn: 'function'
        recordQuery:   'state'
        editor:        'state'
        selectionMode: ['string', true, 'single']
        editorConfig:  { type: 'object' }
        editingController:  'any' # either string or constructor fn

    initialize: ->
        if this.viewport
            this.listenTo(this.viewport,'change:screen_enu_size', this.adjustColumnWidth)
        unless Lanes.current_user.canWrite(this.modelClass)
            this.editRecords = false
            this.addRecords  = false
        unless Lanes.current_user.canDelete(this.modelClass)
            this.deleteRecords = false

    onSort: ->
        return unless @editor
        @editor.remove()
        this.unset('editor')

    onSelect: (ev)->
        [record,row] = ev.detail
        this.grid.unselect(row)

    removeRow: (row)->
        this.dt_api.row(row).remove().draw()

    onCancelEdit: (ev)->
        model = this.modelForRow(ev.detail)
        this.removeRow(ev.detail) if model.isNew()

    reload: ->
        @dt_api.ajax.reload()

    unselect: (row)->
        this.$el.trigger('unselect-row', [@modelForRow(row), {row:row}])
        Lanes.dom.removeClass(row,'active')

    beginEdit: (row,ev)->
        return false unless model = this.modelForRow(row)
        this.createEditor(row) unless @editor
        @editor.move(row,ev)

    createEditor: (row)->
        config = _.extend({ parent: this }, this.editorConfig)
        @editor = switch this.editingController
            when 'row' then new Grid.RowEditor(config)
            when 'popover' then new Grid.PopOverEditor(config)
            else new this.editingController(config)

    deleteRow: ->
        @editor.deleteCurrent()

    createNewRecord: ->
        if @createRecordFn
            @createRecordFn(this)
        else
            new this.modelClass()

    addRow: (record)->
        # create a record if record argument wasn't given or it's an event
        record = this.createNewRecord() if !record || record.type == "click"
        row = this.dt_api.row.add( this._dataFromModel(record) )
        this.apiSettings().oFeatures.bServerSide=false
        row.draw(false)
        this.apiSettings().oFeatures.bServerSide=true
        tr = row.nodes()[0]
        this.$( tr.cells[ tr.cells.length/2 ] ).click()

    apiSettings: ->
        this.dt_api.settings()[0]

    onRowClick: (ev)->
        row = this.$(ev.target).closest('tr')
        if this.editRecords
            this.beginEdit(row,ev)
        if @singleSelectMode
            this.unselect(selected) for selected in this.$('tr.active')

        if row.hasClass('active')
            this.unselect(row)
        else
            row.addClass('active')
            this.$el.trigger('select-row', model, row ) if model = this.modelForRow(row)

    updateRow: (row, model)->
        row.attr('id', model.id)
        this.dt_api.row(row).data(this._dataFromModel(model)).draw()

    modelForRow: (row)->
        data = this.dt_api.row(row).data()
        return null unless data
        return data.model if data.model?.isModel
        attrs = if row.attr('id') then { id: parseInt(row.attr('id')) } else {}
        for field,i in @columnDefinitions
            attrs[field.field] = data[i]
        data.model = new @modelClass(attrs,ignoreUnsaved:true)

    adjustColumnWidth: ->
        @dt_api.columns.adjust()


    onRender: ->
        breakpointDefinition = {
            tablet: 1024,
            phone : 480
        };
        this.dataTable=this.$('table').dataTable(
            deferRender: true
            scrollY: "300px"
            scrollX: true
            serverSide: true
            oClasses: ['table', 'table-stiped', 'table-hover', 'table-condensed']
            bProcessing: true
            bDeferRender: true
            oScroller: { loadingIndicator: true }
            ajax:
                url: @recordQuery.url + ".json"
                data: (d)=>@buildModels(d)
                dataSrc: (d)->
                    d.recordsFiltered = d.recordsTotal = d.total
                    row.DT_RowId = row.shift() for row in d.data
                    d['data']
            dom: "rtiS"
            oScroller:
                rowHeight: 40
            columns: @columnDefinitions
        )
        this.dt_api = this.dataTable.api()
        this

    buildModels: (d)->
        params = {
            o: {}, s: d.start, l: d.length||100, df:'array',
            f: ['id'].concat(_.pluck(@columnDefinitions, 'field'))
        }
        if ! _.isEmpty( query = @recordQuery.asParams() )
            params['q']=query
        for order in d.order
            column = @recordQuery.fields.at(order.column)
            params['o'][column.field] = order.dir
        params


    _makeField: (query_field,index)->
        align = switch query_field.type
            when 'integer','bigdec' then 'r'
            else 'l'
        { title: query_field.title, field: query_field.field, className: align, "targets": [ index ] }

    _dataFromModel: (model)->
        data = []
        for field,i in @columnDefinitions
            data.push( model.get(field.field) || '' )
        data

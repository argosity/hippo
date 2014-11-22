# DataTables class modifications
_.extend( Lanes.$.fn.dataTableExt.oStdClasses,{
    sTable: "table table-striped"
	sWrapper: "dataTables_wrapper form-inline"
	sFilterInput: "form-control input-sm"
	sLengthSelect: "form-control input-sm"
})


class Lanes.Component.Grid extends Lanes.Component.Base

    events:
        'click button.refresh': 'reload'
        'click button.delete':  'deleteRow'
        'click button.create':  'addRow'
        'click tr': 'onRowClick'
        'cancel-edit': 'onCancelEdit'
        'order.dt table': 'onSort'

    templateName: 'grid'
    templateData: ->
        data = { grid: this, buttons: ['refresh'] }
        data['buttons'].push('create') if @add_records
        data['buttons'].push('delete') if @delete_records
        data

    derived:
        column_definitions:
            deps:['record_query'], fn: ->
                @record_query.fields.map(this._make_field, this)

        model_class:
             deps:['record_query'], fn:-> @record_query.model_class

        single_select_mode:
             deps:['selection_mode'], fn:-> @selection_mode == 'single'

    session:
        edit_records:   ['boolean',true,false]
        add_records:    ['boolean',true,false]
        delete_records: ['boolean',true,false]
        record_query:   'state'
        editor:         'state'
        selection_mode: ['string', true, 'single']
        editor_config:  { type: 'object' }
        editing_controller:  'any' # either string or constructor fn

    initialize: (options)->
        this.listenTo(this.ui,'change:screen_menu_size', this.delayedWidthReset)

        unless Lanes.current_user.canWrite(this.model_class)
            this.edit_records = false
            this.add_records  = false
        unless Lanes.current_user.canDelete(this.model_class)
            this.delete_records = false

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
        @fireEvent('unselect-row', @modelForRow(row), {row:row} )
        row.removeClass('active')

    beginEdit: (row,ev)->
        return false unless model = this.modelForRow(row)
        this.createEditor(row) unless @editor
        @editor.move(row,ev)


    createEditor: (row)->
        config = _.extend({ parent: this }, this.editor_config)
        @editor = switch this.editing_controller
            when 'row' then new Grid.RowEditor(config)
            when 'popover' then new Grid.PopOverEditor(config)
            else new this.editing_controller(config)

    deleteRow: ->
        @editor.deleteCurrent()


    addRow: (record)->
        # create a record if record argument wasn't given or it's an event
        record = new this.model_class() if !record || record.type == "click"
        row = this.dt_api.row.add( this._dataFromModel(record) )
        this.api_settings().oFeatures.bServerSide=false
        row.draw(false)
        this.api_settings().oFeatures.bServerSide=true
        this.$( row.nodes() ).click()


    api_settings: ->
        this.dt_api.settings()[0]

    onRowClick: (ev)->
        row = this.$(ev.target).closest('tr')
        if this.edit_records
            this.beginEdit(row,ev)
        else if @single_select_mode
            this.unselect(row) for row in this.$('tr .active')
        else
            if row.hasClass('active')
                this.unselect(row)
            else
                row.addClass('active')
                @fireEvent('select-row', {model:model, row:row} ) if model = this.modelForRow(row)

    updateRow: (row, model)->
        row.attr('id', model.id)
        this.dt_api.row(row).data(this._dataFromModel(model)).draw()


    modelForRow: (row)->
        data = this.dt_api.row(row).data()
        return null unless data
        return data.model if data.model?.isModel
        attrs = if row.attr('id') then { id: parseInt(row.attr('id')) } else {}
        for field,i in @column_definitions
            attrs[field.field] = data[i]
        data.model = new @record_query.model_class(attrs,ignoreUnsaved:true)


    delayedGridConfiguration: ->
        _.delay( =>
            @dt_api.columns.adjust()
        ,500 )


    render: ->
        super
        responsiveHelper = undefined;
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
#            columnDefs: @column_definitions
            ajax:
                url: @record_query.url + ".json"
                data: (d)=>@buildData(d)
                dataSrc: (d)->
                    d.recordsFiltered = d.recordsTotal = d.total
                    row.DT_RowId = row.shift() for row in d.data
                    d['data']
            dom: "rtiS"
            oScroller:
                rowHeight: 40
            columns: @column_definitions
        )
        this.dt_api = this.dataTable.api()

        this.delayedGridConfiguration()
        this

    buildData: (d)->
        params = { o: {}, s: d.start, l: d.length||100, df:'array', f: ['id'].concat(_.pluck(@column_definitions, 'field')) }
        if ! _.isEmpty( query = @record_query.asParams() )
            params['q']=query
        for order in d.order
            column = @record_query.fields.at(order.column)
            params['o'][column.field] = order.dir
        params


    _make_field: (query_field,index)->
        align = switch query_field.type
            when 'integer','bigdec' then 'r'
            else 'l'
        { title: query_field.title, field: query_field.field, className: align, "targets": [ index ] }

    _dataFromModel: (model)->
        data = []
        for field,i in @column_definitions
            data.push( model.get(field.field) || '' )
        data

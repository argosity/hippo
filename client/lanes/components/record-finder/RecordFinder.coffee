class Lanes.Components.RecordFinder extends Lanes.Components.Base
    FILE: FILE

    writeTemplateName: 'field'
    writeTemplateData: ->
        { fieldName: @fieldName || @recordQuery.initialField.id }

    domEvents:
        "keyup .record-finder-query-string": "onKey"
        "click .record-finder-query": "displayFinder"

    session:
        withAssociations: 'array'
        invalid_chars: 'regex'
        recordQuery: 'model'
        gridOptions: 'gridOptions'
        fieldName:  'string'
        queryField: [ 'string', false, 'code' ]

    ui:
        input: '.record-finder-query-string'

    constructor: (options={})->
        super
        this.access = 'write'

    initialize:(options)->
        @recordQuery = new Lanes.Models.Query(
            fields: options.fields, modelClass: options.modelClass
        )

    displayFinder: ->
        finder = new Lanes.Components.RecordFinder.Dialog(
            gridOptions: @gridOptions, parent:this
            title: @title, recordQuery: @recordQuery
        )
        finder.show().then( (dlg)->
            dlg.remove().record
        ).then( (record)=>
            if record
                if @withAssociations then record.withAssociations(@withAssociations...) else record
            else
                null
        ).then( (record)=>
            @.$el.trigger("display-record", record) if record
        , (e)->Lanes.warn(e) )

    onKey: (ev)->
        if 13 == ev.keyCode
            this.runQuery(ev)
        else if @invalid_chars && @ui.input.val().match( @invalid_chars )
            @ui.input.val( @ui.input.val().replace( @invalid_chars, '' ) )

    runQuery: (ev)->
        code = this.$(ev.target).val()
        @recordQuery.loadSingle(code.toUpperCase(),{ include: @withAssociations })
            .then( (reply)=> this.$el.trigger("display-record", reply.record) if reply.record )

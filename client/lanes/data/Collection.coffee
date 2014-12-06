CommonMethods = {
    findIndexWhere: (attrs)->
        found = -1
        for index, model of @models
            found = parseInt(index)
            for key, value of attrs
                if model.get(key) != value
                    found = -1
                    break
            break if found != -1
        found


    destroyAll: (options={})->
        success = options.success
        _.extend( options, {
            data: this.map( (model)-> { id: model.id } )
            success: =>
                for model in @models
                    model.trigger('destroy', model, model.collection, options)
                success.apply(@,arguments) if success
        })
        Lanes.Data.Sync('delete', this, options)

}

class DataCollection

    constructor: ->
        @isLoaded=false
        @errors=[]
        Lanes.Vendor.Ampersand.Collection.apply(this, arguments)

    isLoaded:->
        @isLoaded

    fetch: (options={})->
        @isLoaded = true
        wrapRequest(this,options)
        super(options).then => @

    ensureLoaded: ( callback )->
        if ! @isLoaded && ! this.length
            this.fetch({ success: callback })
        else if callback
            callback()

    isDirty: ->
        false

    parse:(resp)->
        resp['data']

    viewJSON: (options)->
        this.map( (model) ->
            model.viewJSON(options)
        )

    url: ->
        @model::urlRoot()

    sync: ->
        Lanes.Data.Sync.apply(this,arguments)

    _prepareModel: (attrs, options={})->
        options.collection = this;
        if this.isModel(attrs)
            attrs
        else
            this.model.findOrCreate(attrs, options)

    mixins:[
        CommonMethods
    ]

copyServerMessages=(collection,msg)->
    return unless msg
    collection.errors = msg.errors || []
    collection.lastServerMessage = msg.message

wrapRequest = (collection, options)->
    error   = options.error
    success = options.success

    options.error = (collection,resp)->
        copyServerMessages(collection,resp.responseJSON)
        error?.apply(options.scope, arguments)
        Lanes.warn("request fail",resp)
        options.complete?.apply(options.scope, arguments)
    options.success = (collection,resp)->
        copyServerMessages(collection,resp)
        if resp.success
            success?.apply(options.scope, arguments)
        else
            error?.apply(options.scope, arguments)
        options.complete?.apply(options.scope, arguments)

class BasicCollection
    constructor: -> super
    isLoaded: -> true
    mixins:[
        CommonMethods
    ]


class SubCollection
    constructor: -> super
    isLoaded: -> true
    mixins:[
        CommonMethods
    ]

    filter: ->
        this._runFilters()

Lanes.Data.SubCollection = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.SubCollection, SubCollection )


Lanes.Data.BasicCollection = Lanes.lib.MakeBaseClass(
    Lanes.Vendor.Ampersand.Collection.extend(Lanes.Vendor.Ampersand.USCollection), BasicCollection
)


Lanes.Data.Collection = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.RestCollection, DataCollection )

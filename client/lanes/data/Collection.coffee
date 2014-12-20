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
        Lanes.Data.Sync.perform('delete', this, options)

}

class DataCollection

    constructor: ->
        @_isLoaded=false
        @errors=[]
        Lanes.Vendor.Ampersand.Collection.apply(this, arguments)

    @fetch: (options)->
        collection = new this
        collection.fetch(options)
        collection
        
    fetch: (options={})->
        @_isLoaded = true
        Lanes.Data.Sync.wrapRequest(this,options)
        return this.sync('read', this, options)

    # Sets the attribute data from a server respose
    setFromResponse: (data, options)->
        method = if options.reset then 'reset' else 'set'
        this[method](data, options)
        this.trigger('sync', this, data, options)

    isLoaded:->
        @_isLoaded

    ensureLoaded: ( callback )->
        if ! @_isLoaded && ! this.length
            this.fetch({ success: callback })
        else if callback
            callback()

    isDirty: ->
        for model in @models
            return true if model.isDirty()
        false

    parse:(resp)->
        resp['data']

    viewJSON: (options)->
        this.map( (model) ->
            model.viewJSON(options)
        )

    url: ->
        @model::urlRoot()

    sync: Lanes.Data.Sync.perform

    save: (options)->
        Lanes.Data.Sync.perform('update', this, options)

    dataForSave: (options)->
        unsaved = []
        for model in @models
            unsaved.push( model.unsavedData() ) if model.isDirty()
        unsaved

    _prepareModel: (attrs, options={})->
        options.collection = this;
        if this.isModel(attrs)
            attrs
        else
            this.model.findOrCreate(attrs, options)

    mixins:[
        CommonMethods
    ]

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

    url: ->
        this.collection.url()

    filter: ->
        this._runFilters()

Lanes.Data.SubCollection = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.SubCollection, SubCollection )


Lanes.Data.BasicCollection = Lanes.lib.MakeBaseClass(
    Lanes.Vendor.Ampersand.Collection.extend(Lanes.Vendor.Ampersand.USCollection), BasicCollection
)


Lanes.Data.Collection = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.RestCollection, DataCollection )

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

    # convenience method to create a new subCollection
    subcollection: (options)->
        new Lanes.Models.SubCollection(this, options)

    destroyAll: (options={})->
        success = options.success
        _.extend( options, {
            data: this.map( (model)-> { id: model.id } )
            success: =>
                for model in @models
                    model.trigger('destroy', model, model.collection, options)
                success.apply(@,arguments) if success
        })
        Lanes.Models.Sync.perform('delete', this, options)

}

class ModelsCollection

    constructor: ->
        @_isLoaded=false
        @errors=[]
        Lanes.Vendor.Ampersand.Collection.apply(this, arguments)
        this.on('add remove reset', this._triggerLengthEvent )

    _triggerLengthEvent: ->
        this.trigger('change:length', this)

    # convenience method to instantiate a collection
    # then call fetch on it with the options provided
    @fetch: (options)->
        collection = new this
        collection.fetch(options)
        collection

    # Fetch the a set of models for the collection, replacing all
    # current models whith them when the call completes
    fetch: (options={})->
        handlers = Lanes.Models.Sync.wrapRequest(this,options)
        if this.cacheDuration
            Lanes.Models.ServerCache.fetchCollection(this, options)
        else
            this.sync('read', this, options)
        handlers.promise

    ensureLoaded: (options={})->
        handlers = Lanes.Models.Sync.wrapRequest(this,options)
        if options.force || (!@_isLoaded && !this.length )
            this.fetch(options)
        else
            handlers.resolvePromise( record: this, reply: {} )
        handlers.promise

    # Call the callback function when the current fetch succeeds
    # If the collection is not currently being loaded,
    # the callback is immediatly invoked
    whenLoaded: (cb)->
        if this.requestInProgress
            cb(this)
        else
            this._loaded_callbacks ||= []
            this._loaded_callbacks.push(cb)
        this

    # Sets the attribute data from a server respose
    setFromServer: (data, options)->
        @_isLoaded = true
        method = if options.reset then 'reset' else 'set'
        this[method](data, options)
        if this._loaded_callbacks
            cb(this) for cb in this._loaded_callbacks
            delete this._loaded_callbacks

    isLoaded:-> @_isLoaded

    # true if any models have unsaved data
    isDirty: ->
        !!this.findWhere(isDirty: true)

    url: -> @model::urlRoot()

    # Uses Lanes.Models.Sync by default
    sync: (options...)->
        Lanes.Models.Sync.perform(options...)

    save: (options)->
        Lanes.Models.Sync.perform('update', this, options)

    # returns data to save to server.  If options.saveAll is true,
    # all attributes from all models data is returned.
    # Otherwise only unsaved attributes are returned.
    dataForSave: (options)->
        unsaved = []
        for model in @models
            if options.saveAll || model.isDirty
                unsaved.push( model.dataForSave(options) )
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

Lanes.Models.SubCollection = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.SubCollection, SubCollection )

Lanes.Models.BasicCollection = Lanes.lib.MakeBaseClass(
    Lanes.Vendor.Ampersand.Collection.extend(Lanes.Vendor.Ampersand.USCollection), BasicCollection
)

Lanes.Models.Collection = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.RestCollection, ModelsCollection )



## Override a few methods on the standard collection to ensure that
# models are fetched correctly and have the fk set when they're created
class Lanes.Models.AssociationCollection extends Lanes.Models.Collection
    constructor: (models,options)->
        @model = options.model
        @associationFilter = options.filter
        super

    _prepareModel: (attrs, options={})->
        model = super
        model.set(@associationFilter)
        model

    fetch: (options)->
        options.query ||= {}
        _.extend(options.query, @associationFilter)
        super(options)

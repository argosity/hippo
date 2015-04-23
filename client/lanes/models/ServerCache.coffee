class CacheEntry

    constructor: (@collection, @options, @key)->
        @duration = Lanes.Vendor.Moment.duration(@collection.cacheDuration...)
        _.bindAll(this,'setFromServer')
        @successCallback = @options.success
        @options.success = this.setFromServer
        Lanes.Models.Sync.perform('read', this, @options)

    url: ->
        _.result(@collection,'url')

    setFromServer: (reply, status, req)->
        if reply?.data?
            Lanes.Models.ServerCache.store(@key, reply.data, @duration.asMilliseconds())
        @successCallback?.apply(@options.scope, arguments)

    # # needed to
    # trigger: (type, model, xhr, options)->
    #     @collection.trigger(type, @collection, xhr, options)


Lanes.Models.ServerCache = {
    CACHE: {}

    store: (key, data, ms)->
        this.CACHE[key] = data
        setTimeout(->
            delete Lanes.Models.ServerCache.CACHE[key]
        , ms)

    computeCacheKey: (collection, options)->
        url = _.result(collection, "url")
        query = {}
        for key, value of options
            query[ Lanes.Models.Sync.paramsMap[key] ] = value if Lanes.Models.Sync.paramsMap[key]
        url + Lanes.$.param(query)

    fetchRecord: (record, options)->
        key = record.urlRoot()

        if data_set=this.CACHE[key]
            found = false
            for data in data_set
                if record.id == data.id
                    found = data
                    break
        if data_set && found
            options.success.call(options.scope, {data: found}, "sucess", {})
        else
            this.sync('read', this, options)

        false

    fetchCollection: (collection, options)->
        key = this.computeCacheKey(collection, options)
        if this.CACHE[key]
            collection.setFromServer(this.CACHE[key], options)
            options.success.call(options.scope, {data: this.CACHE[key]}, "sucess", {})
        else
            new CacheEntry(collection,options, key)

}

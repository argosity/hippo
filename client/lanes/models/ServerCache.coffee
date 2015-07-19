class CacheEntry

    constructor: (timeout) ->
        @duration = Lanes.Vendor.Moment.duration(timeout...)
        @cache = {}

    store: (record, key) ->
        @cache[key] = {
            data: record
            at: Lanes.Vendor.Moment(new Date)
        }

    get: (key) ->
        entry = @cache[key]
        if entry
            if entry.at.add(this.duration).isAfter(new Date)
                return entry.data
            else
                delete @cache[key]
        null

computeCollectionCacheKey = (collection, options) ->
    url = _.result(collection, "url")
    query = {}
    for key, value of options
        query[ Lanes.Models.Sync.paramsMap[key] ] = value if Lanes.Models.Sync.paramsMap[key]
    url + Lanes.lib.objToParam(query)

Lanes.Models.ServerCache = {
    MODELS: {}
    COLLECTIONS: {}

    storeRecordData: (key, records, timeout, pk) ->
        cache = this.MODELS[key] ||= new CacheEntry(timeout)
        for record in records
            cache.store(record, record[pk])

    fetchRecord: (record, options = {}) ->
        key = record.urlRoot()
        if (cache = this.MODELS[key])
            if (data = cache.get(record.getId()))
                record.setFromServer(data, options)
                return _.Promise.resolve(record)

        record.sync('read', record, options).then (record) ->
            Lanes.Models.ServerCache.storeRecordData(
                key, [record.toJSON()], record.cacheDuration, record.idAttribute
            )
            record

    fetchCollection: (collection, options = {}) ->
        key = computeCollectionCacheKey(collection, options)
        if (cache = this.COLLECTIONS[collection.url()])

            if (data = cache.get(key))
                collection.setFromServer(data, options)
                return _.Promise.resolve(collection)

        collection.sync('read', collection, options).then (collection) ->
            ce = Lanes.Models.ServerCache.COLLECTIONS[key] ||= new CacheEntry(collection.cacheDuration)
            ce.store( collection.toJSON(), key)
            ce.get( key )
            collection

}

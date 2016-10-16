# a simple reimplentation
# to use traffic cop
methodMap = {
    'create': 'POST',
    'update': 'PUT',
    'patch':  'PATCH',
    'delete': 'DELETE',
    'read':   'GET'
}

getValue = (object, prop) ->
    if !(object && object[prop])
        return null
    return if _.isFunction(object[prop]) then object[prop]() else object[prop]

Lanes.Models.Sync = {
    paramsMap:
        fields  : 'f'
        with    : 'w'
        query   : 'q'
        include : 'i'
        order   : 'o'
        limit   : 'l'
        start   : 's'
        format  : 'df'

    urlError: ->
        throw new Error('A "url" property or function must be specified')

    state: (method, model, options = {}) ->
        options.url ||= _.result(model, "url")
        if _.includes(['create', 'update', 'patch'], method)
            isSave = true
            options.json ||= model.dataForSave(options)
        model.requestInProgress = options
        model.trigger("request", model, method, options)
        return new _.Promise (resolve, reject) ->
            handler = (reply) ->
                delete model.requestInProgress
                model.lastServerMessage = reply.message
                if reply.errors or reply.success is false
                    Lanes.warn reply.errors
                    model.errors = reply.errors
                    model.trigger("error", model, options)
                else
                    model.setFromServer(reply.data, options, method)
                    model.trigger("save", model, reply, options) if isSave
                    model.trigger("sync", model, reply, options)

                resolve(model)

            Lanes.Models.Sync.perform(method, options).then (reply) ->
                handler(reply)
            , (err) ->
                reply = { errors: { http:  err?.error?.message or 'unknown' } }
                try
                    reply = JSON.parse(err.body) unless _.isEmpty(err?.body)
                finally
                    handler(reply)



    perform: (method, options = {}) ->
        query = options.queryParams || {}
        for key, value of options
            query[ this.paramsMap[key] ] = value if this.paramsMap[key]

        # Default JSON-request options.
        _.defaults(options, {
            method: methodMap[method]
            dataType: "json"
            json: query
        })

        # Ensure that we have a URL.
        options.url or Lanes.Models.Sync.urlError()

        options.url = '//' + Lanes.config.api_host + options.url + '.json'

        unless _.isEmpty(query)
            options.url += '?' + Lanes.lib.objToParam(query)

        options.headers ||= {}
        options.withCredentials = true
        if Lanes.config.csrf_token
            options.headers['X_CSRF_TOKEN'] = Lanes.config.csrf_token
        options.contentType = "application/json"

        new _.Promise( (resolve, reject) ->
            options.xhr = Lanes.Vendor.xhr(options, (err, resp, body) ->
                if err or resp.statusCode >= 400
                    reject(error:err, body:options.xhr.responseText)
                else
                    resolve(body)
            )
        )


}

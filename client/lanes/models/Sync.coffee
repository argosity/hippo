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
        if _.contains(['create', 'update', 'patch'], method)
            options.data ||= model.dataForSave(options)
        model.requestInProgress = options
        model.trigger("request", model, method, options)
        return new _.Promise (resolve, reject) ->
            handler = (reply) ->
                delete model.requestInProgress
                model.lastServerMessage = reply.message
                if reply.errors
                    Lanes.warn reply.errors
                    model.errors = reply.errors
                    model.trigger("error", model, options)
                    Lanes.React.Viewport.displayError(reply.message) unless options.onError or options.ignoreErrors
                model.setFromServer(reply.data, options, method)
                model.trigger("sync", model, reply, options)
                resolve(model)

            Lanes.Models.Sync.perform(method, options).then (reply) ->
                handler(reply)
            , (err) ->
                reply = { errors: { http: err.error.message } }
                try
                    reply = JSON.parse(err.body) unless _.isEmpty(err?.body)
                finally
                    handler(reply)



    perform: (method, options = {}) ->
        query = {}
        for key, value of options
            query[ this.paramsMap[key] ] = value if this.paramsMap[key]

        # Default JSON-request options.
        _.defaults(options, {
            method: methodMap[method]
            dataType: "json"
            data: query
        })

        # Ensure that we have a URL.
        url = options.url or Lanes.Models.Sync.urlError()
        options.url += '.json'
        unless _.isEmpty(query)
            options.url += '?' + Lanes.lib.objToParam(query)
        if options.data and !_.isString(options.data)
            options.originalData = options.data
            options.data = JSON.stringify( options.data )
        options.headers ||= {}
        options.headers['X_CSRF_TOKEN'] = Lanes.config.csrf_token
        options.contentType = "application/json"

        # Make the request, allowing the user to override any Ajax options.
        # xhr = options.xhr = Lanes.$.ajax(_.extend(params, options))
        new _.Promise( (resolve, reject) ->
            options.xhr = Lanes.Vendor.xhr(options, (err, resp, body) ->
                if err
                    reject(error:err, body:options.xhr.responseText)
                else
                    resolve(JSON.parse(body))
            )
        )


}

# a simple reimplentation
# to use traffic cop
methodMap = {
    'create': 'POST',
    'update': 'PUT',
    'patch':  'PATCH',
    'delete': 'DELETE',
    'read':   'GET'
}

getValue = (object, prop)->
    if !(object && object[prop])
        return null;
    return if _.isFunction(object[prop]) then object[prop]() else object[prop];




paramsMap = {
    fields  : 'f'
    with    : 'w'
    query   : 'q'
    include : 'i'
    order   : 'o'
    limit   : 'l'
    start   : 's'
    format  : 'df'
}

Lanes.Models.Sync = {
    urlError: ->
        throw new Error('A "url" property or function must be specified')

    copyServerReply: (record, reply)->
        record.errors = reply?.errors
        record.lastServerMessage = reply?.message
        { record: record, reply: reply }

    # Wraps a sync request's error and success functions
    # Copies any errors onto the model and sets it's data on success
    wrapRequest: (record, options)->
        error   = options.error
        success = options.success
        options.promise = new _.Promise( (resolve,reject)->
            options.resolvePromise = resolve
            options.rejectPromise  = reject
        )
        options.error = (reply, status, req)->
            options.rejectPromise(
                Lanes.Models.Sync.copyServerReply( record,
                    reply.responseJSON || {error: reply.responseText}
                )
            )
            delete record.requestInProgress
            error?.apply(options.scope, arguments)

        options.success = (reply, status, req)->
            record.setFromServer( reply.data, options ) if reply?.data?
            record.trigger("sync", record, reply, status)
            options.resolvePromise( Lanes.Models.Sync.copyServerReply(record,reply) )
            delete record.requestInProgress
            success?.apply(options.scope, arguments)
        options

    perform: (method, model, options={})->
        query = {}
        for key, value of options
            query[ paramsMap[key] ] = value if paramsMap[key]

        # Default JSON-request options.
        params = {
            type: methodMap[method]
            dataType: "json"
            data: query
        }

        # Ensure that we have a URL.
        params.url = _.result(model, "url") or Lanes.Models.Sync.urlError() unless options.url
        params.url += '.json'
        params.headers = {
            X_CSRF_TOKEN: Lanes.Models.Config.csrf_token
        }
        params.contentType = "application/json"
        if options.data || _.contains(['create','update','patch'], method)
            params.data = JSON.stringify( options.data || model.dataForSave(options) )
            delete options.data

        # Make the request, allowing the user to override any Ajax options.
        xhr = options.xhr = Lanes.$.ajax(_.extend(params, options))
        model.requestInProgress = true
        model.trigger("request", model, xhr, options)
        xhr
}

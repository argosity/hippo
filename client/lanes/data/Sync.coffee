
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


urlError = ->
    throw new Error('A "url" property or function must be specified')


paramsMap = {
    fields  : 'f'
    with    : 'w'
    query   : 'q'
    include : 'i'
    order   : 'o'
    limit   : 'l'
    start   : 's'
}

Lanes.Data.Sync = (method, model, options={})->

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
    params.url = _.result(model, "url") or urlError() unless options.url
    params.url += '.json'
    params.headers = {
        X_CSRF_TOKEN: Lanes.Data.Config.csrf_token
    }
    params.contentType = "application/json"
    if options.data || _.contains(['create','update','patch'], method)
        params.data = JSON.stringify( options.data || model.dataForSave(options) )
        delete options.data

    # Don't process data on a non-GET request.
    #params.processData = false if params.type isnt "GET"

    # Make the request, allowing the user to override any Ajax options.
    xhr = options.xhr = Lanes.$.ajax(_.extend(params, options))
    model.trigger "request", model, xhr, options
    xhr

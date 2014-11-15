Lanes.lib.results = {
    # Like underscore's results but allows passing
    # arguments to the function if it's called
    resultsFor:( method, args... )->
        if _.isString(method)
            if _.isFunction(this[method])
                this[method].apply(this,args)
            else
                this[method]
        else if _.isFunction(method)
            method.apply(this,args)
        else
            method

}

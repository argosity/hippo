Lanes.lib.results = {
    # Like underscore's results but allows passing
    # arguments to the function if it's called
    resultsFor:( method, args... )->
        Lanes.u.resultsFor(this,method,args...)

}

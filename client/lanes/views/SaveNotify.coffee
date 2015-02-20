class ModelSaver

    constructor: ( @element, @options )->
        @mask = new Lanes.Views.TimedMask( @element, @options.message )
        @mask.prefixActions( "Save" )
        _.bindAll(this,'_onError','_onSuccess')
        this.notification = new _.DeferredPromise

    save: ->
        @options.model.save({
            success: this._onSuccess, error: this._onError
        })

    _onSuccess: (data,success,resp)->
        @mask.displaySuccess()
        this._callback(true,data,resp)

    _onError: (data,success,resp)->
        @mask.displayFailure(@options.model.lastServerMessage)
        this._callback(false,data,resp)

    _callback: (success,data,resp)->
        @options.callback(success,resp,@options.model) if @options.callback
        this.notification?.resolve(data: data.data, success: success, response: resp)


Lanes.Views.SaveNotify = ( view, options={} )->
    el = if view.jquery then view else view.$el
    _.defaults( options, { model: view.model, message: "Saving, Please Wait…"} )
    ms = new ModelSaver(el, options)
    ms.save()
    return ms.notification.promise


class ModelSaver

    constructor: ( @element, @options )->
        @mask = new Lanes.Views.TimedMask( @element, @options.message )
        @mask.prefixActions( "Save" )
        _.bindAll(this,'_onError','_onSuccess')

    save: ->
        @options.model.save({
            success: this._onSuccess, error: this._onError
        })

    _onSuccess: (rec,resp,options)->
        @mask.displaySuccess()
        this._callback(true,resp)

    _onError: (rec,resp,options)->
        @mask.displayFailure(rec.lastServerMessage)
        this._callback(false,resp)

    _callback: (success,resp)->
        @options.callback(success,resp,@options.model) if @options.callback


Lanes.Views.SaveNotify = ( view, options={} )->
    el = if view.jquery then view else view.$el
    _.defaults( options, { model: view.model, message: "Saving, Please Wait…"} )
    ms = new ModelSaver(el, options)
    ms.save()

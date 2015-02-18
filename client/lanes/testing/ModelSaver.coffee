class Lanes.Testing.ModelSaver

    @perform: (model,completion)->
        saver = new Lanes.Testing.ModelSaver(completion)
        saver.save(model)

    constructor: (@completion)->
        _.bindAll(this,'success','error')
        spyOn(this, 'success').and.callThrough()
        spyOn(this, 'error').and.callThrough()

    success: ->
        this.notification.resolve(this)
        _.defer(@completion) if @completion

    error: ->
        this.notification.resolve(this)
        _.defer(@completion) if @completion

    save: (model)->
        model.save(this)
        this.notification = new _.DeferredPromise
        this.notification.promise

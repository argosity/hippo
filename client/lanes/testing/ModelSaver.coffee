class Lanes.Test.ModelSaver

    @setUser: (login)->
        Lanes.Test.ModelSaver::headers['X_TESTING_USER']= login

    @perform: (model,completion)->
        saver = new Lanes.Test.ModelSaver(completion)
        saver.save(model)

    headers:
        X_ROLLBACK_AFTER_REQUEST: true

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
        Lanes.Models.Sync.callOriginal =>
            model.save(@toOptions()).then(Lanes.emptyFn, Lanes.emptyFn)
        this.notification = new _.DeferredPromise
        this.notification.promise

    toOptions: ->
        _.pick(this,'headers','success','error')

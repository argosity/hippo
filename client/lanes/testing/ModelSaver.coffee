class Lanes.Test.ModelSaver

    @setUser: (login) ->
        Lanes.Test.ModelSaver::headers['X_TESTING_USER'] = login

    @perform: (model, completion) ->
        saver = new Lanes.Test.ModelSaver(completion)
        saver.save(model)

    headers:
        X_ROLLBACK_AFTER_REQUEST: true

    constructor: (completion) ->
        @done = completion

    save: (model) ->
        @model = model
        me = this
        return new _.Promise (resolve) ->
            Lanes.Models.Sync.restorePerform ->
                model.save(_.pick(me, 'headers')).then ->
                    resolve(me)
                    _.defer(me.done) if me.done

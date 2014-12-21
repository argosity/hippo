class Lanes.Views.ModelObserver extends Lanes.Models.State

    model_events: {}

    constructor: (@view, @keypath='model')->
        super
        @view.on( "change:#{@keypath}", this.rebindModel,   this )
        @view.on( "remove",             this.teardown,      this )
        this.rebindModel()

    getModel: ->
        @cached_model ||= Lanes.getPath(@keypath, @view)

    unBindModel: (model)->
        for event, fn of @model_events
            model.off(event, this[fn], this )

    bindModel: (model)->
        for event, fn of @model_events
            model.on(event, this[fn], this )

    rebindModel: ->
        @cached_model=null
        old_model = @view.previous(@keypath)
        new_model = this.getModel()
        return if old_model == new_model
        this.unBindModel( old_model ) if old_model
        this.bindModel(   new_model ) if new_model

    teardown: ->
        this.unBindModel( model ) if model = this.getModel()

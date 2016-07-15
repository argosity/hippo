class Lanes.Screens.Commands extends Lanes.Models.State

    constructor: (@screen, @options = {}) ->
        _.defaults(@options, modelName: 'model')
        _.bindAll(this, _.functionsIn(this))

    resetModel: ->
        model = @getModel()
        @setModel( new model.constructor )
        undefined

    getModel: -> @screen[@options.modelName]

    setModel: (model) ->
        @options.modelWillRebind?(model)
        @screen.modelBindings.reset({"#{@options.modelName}": model})
        @screen.setModelUrl?(model)
        @options.modelDidRebind?(model)

    canEditModel: ->
        @screen.hasWriteAccess?()

    getSyncOptions: ->
        _.result(@screen, 'syncOptions') || {}

    saveModel: ->
        @getModel().save(@getSyncOptions())

    toggleEdit: ->
        @screen.setState(isEditing: !@isEditing())

    isEditing: ->
        !!@screen.state.isEditing

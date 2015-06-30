class Lanes.Screens.Commands

    constructor: (@screen, @options = {}) ->
        _.defaults(@options,
            modelName: 'model'
        )
        _.bindAll(this, _.functions(this))

    resetModel: ->
        model = @getModel()
        @setModel( new model.constructor )
        undefined

    getModel: ->
        @screen[@options.modelName]

    setModel: (model) ->
        @screen.data.rebind("#{@options.modelName}": model)

    saveModel: ->
        @getModel().save()

    toggleEdit: ->
        @screen.setState(isEditing: !@isEditing())

    isEditing: ->
        !!@screen.state.isEditing

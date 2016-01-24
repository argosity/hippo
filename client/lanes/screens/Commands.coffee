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

    canPrint: ->
        model = @getModel()
        not model.isNew() and model?.pdfDownloadUrl

    printModel: ->
        model = @getModel()
        window.open(_.result(model, 'pdfDownloadUrl'), 'lanes-print')

    getModel: -> @screen[@options.modelName]

    setModel: (model) ->
        @options.modelWillRebind?(model)
        @screen.data.rebind("#{@options.modelName}": model)
        @screen.setModelUrl?(model)
        @options.modelDidRebind?(model)

    saveModel: ->
        @getModel().save()

    toggleEdit: ->
        @screen.setState(isEditing: !@isEditing())

    isEditing: ->
        !!@screen.state.isEditing

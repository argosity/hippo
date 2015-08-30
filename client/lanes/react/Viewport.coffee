ALL_INSTANCES = []

class Lanes.React.Viewport extends Lanes.Models.State

    @all: -> ALL_INSTANCES
    @displayError: (msg) -> _.first(ALL_INSTANCES)?.displayError(msg)

    session:
        width:      'number'
        height:     'number'
        el:         'element'
        selector:   'string'
        root:       'element'
        modalProps: 'object'

    constructor: ->
        super
        ALL_INSTANCES.push(this)
        root = document.body.querySelector(@selector)
        _.dom(root).addClass('lanes-root')
        Lanes.fatal("Root selector #{@selector} not found") unless root
        _.dom(root).html = "<div class='lanes'/>"
        Lanes.lib.ResizeSensor(root, _.debounce( =>
            @_updateDimensions()
        , 250))
        this.root = root.querySelector('.lanes')
        this._updateDimensions()

    _updateDimensions: ->
        this.set
            width:  this.root.clientWidth
            height: this.root.clientHeight


    displayError: (msg) ->
        @modalProps = {
            show: true, buttons: ['OK'], title: 'Error', body: React.createElement('h3', {}, msg)
        }

    hideModal: ->
        @modalProps = {show: false}

    displayModal: (props) ->
        new _.Promise( (onOk, onCancel) =>
            @modalProps = _.extend(props, show: true, {onCancel, onOk})
        )

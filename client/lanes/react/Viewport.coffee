ALL_INSTANCES = []

class Lanes.React.Viewport extends Lanes.Models.State

    @all: -> ALL_INSTANCES

    session:
        width:      'number'
        height:     'number'
        el:         'element'
        selector:   'string'
        root:       'element'

    constructor: ->
        super
        ALL_INSTANCES.push(this)
        root = document.body.querySelector(@selector)
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

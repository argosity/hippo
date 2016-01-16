ALL_INSTANCES = []

class Lanes.React.Viewport extends Lanes.Models.State

    @all: -> ALL_INSTANCES
    @displayError: (msg) -> _.first(ALL_INSTANCES)?.displayError(msg)

    session:
        width:      'number'
        height:     'number'
        el:         'element'
        selector:   'string'
        domRoot:    'element'
        reactRoot:  'object'
        lanes:      'element'
        modalProps: 'object'

    constructor: ->
        super
        ALL_INSTANCES.push(this)
        return unless @selector
        @domRoot = document.body.querySelector(@selector)
        _.dom(@domRoot).addClass('lanes-root')
        Lanes.fatal("Root selector #{@selector} not found") unless root
        _.dom(@domRoot).html = "<div class='lanes'/>"
        this.lanes = @domRoot.querySelector('.lanes')
        Lanes.lib.ResizeSensor(@domRoot, _.debounce( =>
            @_updateDimensions()
        , 250))
        this._updateDimensions()

    onBoot: ->
        prev = _.dom(this.domRoot.previousElementSibling)
        prev.addClass('complete') if prev.hasClass('loading')
        _.delay(->
            prev.remove()
        , 1000)

    _updateDimensions: ->
        this.set
            width:  @lanes.clientWidth
            height: @lanes.clientHeight


    displayError: (msg) ->
        @modalProps = {
            show: true, buttons: ['OK'], title: 'Error',
            body: -> React.createElement('h3', {}, msg)
        }

    hideModal: ->
        @modalProps = {show: false}

    displayModal: (props) ->
        new _.Promise( (onOk, onCancel) =>
            @modalProps = _.extend(props, show: true, {onCancel, onOk})
        )

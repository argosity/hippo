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
        pubSubDisabled: 'boolean'
        rootComponent: 'any'
        rootProps:   'object'
        rootElement:  'object'

    constructor: ->
        super
        ALL_INSTANCES.push(this)
        return unless @selector
        @domRoot = document.body.querySelector(@selector)
        _.dom(@domRoot).addClass('lanes-root')
        Lanes.fatal("Root selector #{@selector} not found") unless @domRoot
        _.dom(@domRoot).html = "<div class='lanes'/>"
        this.lanes = @domRoot.querySelector('.lanes')

        Lanes.lib.ResizeSensor(@domRoot, _.debounce( =>
            @_updateDimensions()
        , 250))
        this._updateDimensions()

        Lanes.Models.PubSub.initialize() unless @pubSubDisabled
        Lanes.Extensions.fireOnInitialized(@)
        @renderRoot()
        Lanes.Extensions.fireOnAvailable(@)
        @onBoot()


    onBoot: ->
        prev = _.dom(this.domRoot.previousElementSibling)
        if prev.hasClass('loading')
            prev.addClass('complete')
            _.delay(->
                prev.remove()
            , 100)

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
        @modalProps = _.extend(props, show: true)

    renderRoot: ->
        component = @rootComponent || (
            cntrl = Lanes.Extensions.controlling()
            component = cntrl?.rootComponent?(this) ||
                Lanes.React.Root.DefaultComponentNotFound
        )
        @rootElement = React.createElement(Lanes.React.Root, {viewport: @},
            React.createElement(component, _.extend(@rootProps, extension: cntrl))
        )
        @reactRoot = Lanes.Vendor.ReactDOM.render(@rootElement, @lanes)

ALL_INSTANCES = []
class FakeHistory
    push:    Lanes.emptyFn
    replace: Lanes.emptyFn

class Lanes.React.Viewport extends Lanes.Models.State

    @all: -> ALL_INSTANCES
    @displayError: (msg) -> _.first(ALL_INSTANCES)?.displayError(msg)

    session:
        width:          'number'
        height:         'number'
        el:             'element'
        selector:       'string'
        container:      'element'
        reactRoot:      'object'
        lanes:          'element'
        modalProps:     'object'
        pubSubDisabled: 'boolean'
        rootComponent:  'any'
        rootProps:      'object'
        rootElement:    'object'
        history:        'object'
        useHistory:     {type: 'boolean', default: true}

    constructor: ->
        super
        ALL_INSTANCES.push(this)
        unless (@container or (@selector and
                (@container = document.body.querySelector(@selector))))
            console.warn("Unable to render without container or valid selector")
            return

        _.dom(@container).addClass('lanes-root')
        Lanes.fatal("Root selector #{@selector} not found") unless @container
        _.dom(@container).html = "<div class='lanes'/>"
        this.lanes = @container.querySelector('.lanes')

        Lanes.lib.ResizeSensor(@container, _.debounce( =>
            @_updateDimensions()
        , 250))
        this._updateDimensions()

        Lanes.Models.PubSub.initialize() unless @pubSubDisabled
        Lanes.Extensions.fireOnInitialized(@)
        @renderRoot()
        Lanes.Extensions.fireOnAvailable(@)
        @onBoot()


    onBoot: ->
        prev = _.dom(this.container.previousElementSibling)
        if @useHistory
            @initializeHistory()
        else
            @history = new FakeHistory
        if prev.hasClass('loading')
            prev.addClass('complete')
            _.delay(->
                prev.remove()
            , 100)

    initializeHistory: ->
        useBasename = Lanes.Vendor.BrowserHistory.useBasename

        @history = useBasename(Lanes.Vendor.BrowserHistory.createHistory)({
            basename: Lanes.config.root_path
        })
        @_historyStopListening = @history.listen (location) ->
            Lanes.Screens.Definitions.setBrowserLocation(location)

        Lanes.Screens.Definitions.setBrowserLocation(
            @history.getCurrentLocation()
        )

        Lanes.Screens.Definitions.displaying.on('change:active', (screen) =>
            if screen.active
                @history.replace(screen.historyUrl())
            if Lanes.Screens.Definitions.displaying.length is 0
                @history.push('/')
        )

    close: ->
        @hideModal()
        @_historyStopListening?()
        @container.remove()

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

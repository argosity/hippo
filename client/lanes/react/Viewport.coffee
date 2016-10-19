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
        domRoot:        'element'
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

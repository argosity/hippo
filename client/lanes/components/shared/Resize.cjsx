# ###* @jsx React.DOM ###

# React = require('react')
# ZyngaScroller = require('react-touch/lib/environment/ZyngaScroller')
# AnimatableContainer = require('react-touch/lib/primitives/AnimatableContainer')
# TouchableArea = require('react-touch/lib/primitives/TouchableArea')
# ANIMATABLE_CONTAINER_STYLE =
#     bottom: 0
#     left: 0
#     position: 'absolute'
#     right: 0
#     top: 0

# ###*
# SimpleScroller component from react-touch, with event for detecting content resizes with overflow/underflow events.
# See these articles:
# http://www.backalleycoder.com/2013/03/14/oft-overlooked-overflow-and-underflow-events/
# http://www.backalleycoder.com/2013/03/18/cross-browser-event-based-element-resize-detection/
# *
# ###

Lanes.Components.Resize = React.createClass

    addFlowListener: (element, type, fn) ->
        flow = type == 'over'
        event = if 'OverflowEvent' of window then 'overflowchanged' else "#{type}flow"
        element.addEventListener( event, ((e) ->
            if (e.type == "#{type}flow") || ((e.orient == 0 && e.horizontalOverflow == flow) || (e.orient == 1 && e.verticalOverflow == flow) ||  (e.orient == 2 && e.horizontalOverflow == flow && e.verticalOverflow == flow))

                e.flow = type
                return fn.call(this, e)

            return
        ), false)

    fireEvent: (element, type, data, options = {}) ->
        # event = document.createEvent('Event')
        # event.initEvent(type,  if 'bubbles' of options then options.bubbles else true, if 'cancelable' of options then options.cancelable else true)
        # for z of data
        #     event[z] = data[z]
        # element.dispatchEvent event
        # return

    addResizeListener: (element, fn) ->
        resize = 'onresize' of element
        if !resize and !element._resizeSensor
            sensor = element._resizeSensor = React.findDOMNode(@refs.sensor)
            x = 0
            y = 0
            first = sensor.firstElementChild.firstChild
            last = sensor.lastElementChild.firstChild
            matchFlow = ((event) ->
                change = false
                width = element.offsetWidth
                if x != width
                    first.style.width = width - 1 + 'px'
                    last.style.width = width + 1 + 'px'
                    change = true
                    x = width
                height = element.offsetHeight
                if y != height
                    first.style.height = height - 1 + 'px'
                    last.style.height = height + 1 + 'px'
                    change = true
                    y = height
                if change and event.currentTarget != element
                    @fireEvent element, 'resize'
                return
            ).bind(this)
            if getComputedStyle(element).position == 'static'
                element.style.position = 'relative'
                element._resizeSensor._resetPosition = true
            @addFlowListener sensor, 'over', matchFlow
            @addFlowListener sensor, 'under', matchFlow
            @addFlowListener sensor.firstElementChild, 'over', matchFlow
            @addFlowListener sensor.lastElementChild, 'under', matchFlow
            matchFlow {}
        events = element._flowEvents or (element._flowEvents = [])
        if events.indexOf(fn) == -1
            events.push fn
        if !resize
            element.addEventListener 'resize', fn, false

        element.onresize = (e) ->
            events.forEach (fn) ->
                fn.call element, e
                return
            return

        return
    removeResizeListener: (element, fn) ->
        index = element._flowEvents.indexOf(fn)
        if index > -1
            element._flowEvents.splice index, 1
        if !element._flowEvents.length
            sensor = element._resizeSensor
            if sensor
                if sensor._resetPosition
                    element.style.position = 'static'
            if 'onresize' of element
                element.onresize = null
            delete element._flowEvents
        element.removeEventListener 'resize', fn
        return
    handleContentResize: (e) ->
        if @configured
            # re-calculate the dimensions of the Scroller
            @configured = false
            @configure()
        return
    getInitialState: ->
        {
            left: 0
            top: 0
        }
    componentWillMount: ->
        @configured = false

    componentWillUnmount: ->
        # remove event listeners
        node = React.findDOMNode(@refs.content)
        @removeResizeListener node, @handleContentResize

    componentDidMount: ->
        # attach event listeners
        node = React.findDOMNode(@refs.content)
        @addResizeListener node, @handleContentResize
        @configure()

    componentDidUpdate: ->
        @configure()

    configure: ->
        if @configured
            return
        @configured = true
        node = React.findDOMNode(@refs.content)
        @props.onResize(width: node.clientWidth, height: node.clientHeight)

        # @scroller.setDimensions @getDOMNode().clientWidth, @getDOMNode().clientHeight, node.clientWidth, node.clientHeight

    # handleScroll: (left, top) ->
    #     @setState({left, top})

    render: ->
        <div ref="content">
            {this.props.children}
            <div ref="sensor" className="resize-sensor">
                <div className="resize-overflow"><div></div></div>
                <div className="resize-underflow"><div></div></div>
            </div>
        </div>

class State
    constructor: ->
        super
        @_bindEvent(eventSpec, fnName) for eventSpec, fnName of _.result(@, 'events', {})
        @

    _bindEvent: (eventSpec, fnName) ->
        [kp, event] = eventSpec.split(' ')
        unless event
            event = kp; kp = ''
        _.get(@, kp, @).on(event, @[fnName], @)


    isState: true
    dataTypes:
        function:
            set: (fn) ->
                if _.isBlank(fn) or _.isFunction(fn)
                    { val: fn, type: 'function' }
                else
                    throw new TypeError
        element:
            set: (el) ->
                if _.isBlank(el) or _.isElement(el)
                    { val: el, type: 'element' }
                else
                    throw new TypeError

        collection:
            set: (c) ->
                if _.isBlank(c) or Lanes.u.isCollection(c) or _.isArray(c)
                    { val: c, type: 'collection' }
                else
                    throw new TypeError
        code:
            set: (newVal) ->
                newVal = '' if !newVal?
                if _.isString(newVal)
                    val: newVal.toUpperCase(), type: 'code'
                else
                    throw new TypeError('code must be a string')
            default: -> ''
        # Big decimal for attributes that need precision math
        bigdec:
            set: (newVal) ->
                val = _.bigDecimal(newVal) unless _.isBlank(newVal)
                { val, type: 'bigdec' }
            default: -> new _.bigDecimal(0)

        integer:
            set: (newVal) ->
                val = parseInt(newVal, 10) unless _.isBlank(newVal)
                {val, type: 'integer'}

        moment:
            get: (val)    -> _.moment(val)
            default:      -> _.moment()
            set: (newVal) -> { val: _.moment(newVal), type: 'moment' }
            compare: (currentVal, newVal) -> currentVal.isSame(newVal)

        # Uses the "moment" lib to parse dates and coerce strings into the date type.
        date:
            get: (val) -> new Date(val)
            default: -> return new Date()
            set: (newVal) ->
                if _.isDate(newVal)
                    type = 'date'
                    val = new Date(newVal)
                else if newVal
                    m = Lanes.Vendor.Moment(Date.parse(newVal))
                    if m.isValid()
                        type = 'date'
                        val = m.toDate()
                    else
                        type = typeof newVal;
                return { type, val }

    # ## listenToAndRun
    # Shortcut for registering a listener for a model
    # and also triggering it right away.
    listenToAndRun: (object, events, handler) ->
        bound = _.bind(handler, this)
        this.listenTo(object, events, bound)
        bound()

Lanes.Models.State = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.State, State )

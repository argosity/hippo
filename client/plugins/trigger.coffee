
jqTrigger = Lanes.$.fn.trigger

Lanes.$.fn.trigger = ( event, data, elem, onlyHandlers ) ->
    evt = window.document.createEvent('CustomEvent')
    event_name = if _.isObject(event)
        data ||= event
        event.type
    else
        event
    evt.initCustomEvent(event_name, true, true, data )
    this.each( (index,el)->
        el.dispatchEvent(evt) unless _.isFunction(el[event_name])
    )
    jqTrigger.apply(this, arguments);

class Lanes.lib.Dom

    constructor: (el) ->
        @el = el

    qs: (selector, options = {}) ->
        el = @el.querySelector(selector)
        if not el and options.raise isnt false
            throw new TypeError("Unable to find element for selector #{selector}")
        new Lanes.lib.Dom(el || @el)

    qsa: (selector) ->
        @el.querySelectorAll(selector)

    remove: ->
        @el.parentElement.removeChild(@el)

    focusAndSelect: ->
        @el.select()
        @el.focus()

wrapArg = (fn) ->
    return ->
        fn(this.el, arguments...)

chain = (fn) ->
    return ->
        fn(this.el, arguments...)
        return this

for name, func of Lanes.Vendor.dom
    Lanes.lib.Dom::[name] = if name.match(/^has/)
        wrapArg
    else
        chain(func)

Object.defineProperties(Lanes.lib.Dom.prototype, {

    text:
        get: -> @el.textContent
        set: (txt) ->
            Lanes.Vendor.dom.text(@el, txt)
    html:
        get: -> @el.innerHTML
        set: (html) ->
            Lanes.Vendor.dom.html(@el, html)

    value:
        get: -> @el.value
        set: (v) -> @el.value = v
})



_.dom = (unknown, query) ->
    el = if _.isBlank(unknown)
        throw new TypeError("Selector / DOM node is not present")
    else if _.isElement(unknown)
        unknown
    else if unknown.isReactComponent
        Lanes.Vendor.ReactDOM.findDOMNode(unknown)
    else if unknown.nodeType is 9 # body tag
        unknown
    else if unknown
        throw new TypeError("Unable to obtain dom reference to #{unknown}")

    if query
        el = el.querySelector(query)
    new Lanes.lib.Dom(el)

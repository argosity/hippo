##=require lanes/remote/onDocumentReady
##=require lanes/lib/loader
##=require_self

LOADING  =  1
ERROR    = -1
COMPLETE = 99

ASSETS_PREFIX = '/assets/'

class Bootstrapper

    constructor:(@options) ->
        @srcTagSubstrIndx = @options.srcTag.length * -1
        @callbacks = { onComplete: [] }
        @onComplete(@options.onComplete) if @options.onComplete

        Lanes.Remote.onDocumentReady =>
            @readLoadUrl()

    tagMatchesSuffix: (tag) ->
        tag.src.substr(@srcTagSubstrIndx) == @options.srcTag

    readLoadUrl: ->
        for tag in document.querySelectorAll('script') when @tagMatchesSuffix(tag)
            @api_host = tag.src.replace(/\/assets\/.*/, '')
            break
        if @api_host
            @requestFullAssets()
        else
            @state = ERROR
            console.error("Unable to find script tag that Stockor was loaded from")

    srcFor: (type) ->
        @api_host + ASSETS_PREFIX + @options.scripts[type]

    requestFullAssets: ->
        @pending = {}
        if @options.scripts.js
            @pending.js = Lanes.lib.loader.js(@srcFor('js'), (ev) =>
                @onLoadComplete(ev)
            )
        if @options.scripts.css
            @pending.css = Lanes.lib.loader.css(@srcFor('css'), (ev) =>
                @onLoadComplete(ev)
            )
        @setLoadingStatus()

    setLoadingStatus: ->
        if Object.keys(@pending).length
            @state = LOADING
        else
            @state = COMPLETE
            Lanes.config.api_host = @api_host
            for cb in @callbacks.onComplete
                cb(@)

    onComplete: (cb) ->
        @callbacks.onComplete.push(cb)

    onLoadComplete: (tag) ->
        switch tag.tagName
            when 'LINK'   then delete @pending.css
            when 'SCRIPT' then delete @pending.js
            else
                console.warn "Complete called for unknown tag type #{tag.tagName}"
        @setLoadingStatus()



Object.defineProperties(Bootstrapper.prototype, {

    isComplete:
        get: -> @state == COMPLETE
    isPending:
        get: -> @state isnt COMPLETE and @state isnt ERROR
    hasFailed:
        get: -> @state isnt ERROR

})

Lanes.namespace('Bootstrap')

Lanes.Remote.Bootstrap = (srcTag, options) ->
    new Bootstrapper(srcTag, options)

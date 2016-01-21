###jshint bitwise: false###

###*
  Message Bus functionality.

  @class MessageBus
  @namespace Discourse
  @module Discourse
*
###

Lanes.Vendor.MessageBus = do ->

    hiddenProperty = undefined
    prefixes = ["", "webkit", "ms", "moz"]
    for prefix in prefixes
        check = prefix + ( if prefix == "" then "hidden" else "Hidden" )
        unless _.isUndefined(document[check])
            hiddenProperty = check
            break

    isHidden = ->
        if hiddenProperty
            document[hiddenProperty]
        else
            not document.hasFocus

    # http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
    callbacks = undefined
    clientId = undefined
    failCount = undefined
    shouldLongPoll = undefined
    queue = undefined
    responseCallbacks = undefined
    uniqueId = undefined
    baseUrl = undefined
    me = undefined
    started = undefined
    stopped = undefined
    longPoller = undefined
    pollTimeout = undefined

    uniqueId = ->
        'xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'.replace /[xy]/g, (c) ->
            r = undefined
            v = undefined
            r = Math.random() * 16 | 0
            v = if c == 'x' then r else r & 0x3 | 0x8
            v.toString 16

    clientId = uniqueId()
    responseCallbacks = {}
    callbacks = []
    queue = []
    interval = null
    failCount = 0
    baseUrl = '/'

    hiddenProperty = undefined
    _.each ['', 'webkit', 'ms', 'moz', 'ms'], (index, prefix) ->
        check = prefix + (if prefix == '' then 'hidden' else 'Hidden')
        if document[check] != undefined
            hiddenProperty = check
        return

    isHidden = ->
        if hiddenProperty != undefined
            document[hiddenProperty]
        else
            !document.hasFocus

    shouldLongPoll = ->
        me.alwaysLongPoll or !isHidden()

    totalAjaxFailures = 0
    totalAjaxCalls = 0
    lastAjax = undefined

    longPoller = (poll, data) ->
        gotData = false
        aborted = false
        lastAjax = new Date
        totalAjaxCalls += 1

        error = (err, resp, body) ->
            if me.aborted
                aborted = true
                me.aborted = false
            else
                failCount += 1
                totalAjaxFailures += 1

        success = (body) ->
            messages = JSON.parse(body)
            failCount = 0
            if messages == null
                return
            # server unexpectedly closed connection
            _.each messages, (message) ->
                gotData = true
                _.each callbacks, (callback) ->
                    if callback.channel == message.channel
                        callback.last_id = message.message_id
                        try
                            callback.func message.data
                        catch e
                            if console.log
                                console.log 'MESSAGE BUS FAIL: callback ' +
                                    callback.channel + ' caused exception ' +
                                    e.message
                    if message.channel == '/__status'
                        if message.data[callback.channel] != undefined
                            callback.last_id = message.data[callback.channel]
                    return
                return

        complete = ->
            interval = undefined
            try
                if gotData or aborted
                    interval = 100
                else
                    interval = me.callbackInterval
                    if failCount > 2
                        interval = interval * failCount
                    else if !shouldLongPoll()
                        # slowing down stuff a lot when hidden
                        # we will need to fine tune this
                        interval = interval * 4
                    if interval > me.maxPollInterval
                        interval = me.maxPollInterval
                    interval -= new Date - lastAjax
                    if interval < 100
                        interval = 100
            catch e
                if console.log and e.message
                    console.log 'MESSAGE BUS FAIL: ' + e.message
            _.delay(poll, interval)
            me.longPoll = null

        options = {
            url: me.baseUrl + 'message-bus/' + me.clientId + '/poll?'
            body: Lanes.lib.objToParam(data)
            timeout: pollTimeout
            method: 'POST'
            headers:
                'Dont-Chunk': 'true'
                'Content-Type': 'multipart/form-data'
                'X_CSRF_TOKEN': Lanes.config.csrf_token
                'X-SILENCE-LOGGER': 'true'
        }
        if !shouldLongPoll() or !me.enableLongPolling
            options.url += 'dlp=t'
        Lanes.Vendor.xhr(options, (err, resp, body) ->
            if err then error(err, resp, body) else success(body)
            complete()
        )

    me =
        enableLongPolling: true
        callbackInterval: 15000
        maxPollInterval: 3 * 60 * 1000
        callbacks: callbacks
        clientId: clientId
        alwaysLongPoll: false
        baseUrl: baseUrl
        diagnostics: ->
            console.log 'Stopped: ' + stopped + ' Started: ' + started
            console.log 'Current callbacks'
            console.log callbacks
            console.log 'Total ajax calls: ' + totalAjaxCalls + ' Recent failure count: ' + failCount + ' Total failures: ' + totalAjaxFailures
            console.log 'Last ajax call: ' + (new Date - lastAjax) / 1000 + ' seconds ago'
            return
        stop: ->
            stopped = true
            started = false
            return
        start: (opts) ->
            poll = undefined
            if started
                return
            started = true
            stopped = false
            if !opts
                opts = {}

            poll = ->
                data = undefined
                if stopped
                    return
                if callbacks.length == 0
                    setTimeout poll, 500
                    return
                data = {}
                _.each callbacks, (callback) ->
                    data[callback.channel] = callback.last_id
                    return
                me.longPoll = longPoller(poll, data)
                return

            poll()
            return
        subscribe: (channel, func, lastId) ->
            if !started and !stopped
                me.start()
            if typeof lastId != 'number' or lastId < -1
                lastId = -1
            callbacks.push
                channel: channel
                func: func
                last_id: lastId
            if me.longPoll
                me.aborted = true
                return me.longPoll.abort()
            return
        unsubscribe: (channel) ->
            # TODO proper globbing
            glob = undefined
            if channel.indexOf('*', channel.length - 1) != -1
                channel = channel.substr(0, channel.length - 1)
                glob = true
            _.remove(callbacks, (callback) ->
                if glob
                    callback.channel.substr(0, channel.length) == channel
                else
                    callback.channel == channel
            )
            if me.longPoll
                me.longPoll.abort()
                me.longPoll = false
    me

# inspiration from https://github.com/ramitos/lazyload/blob/master/src/lazyload.js
#
GECKO = /Gecko\//.test(navigator.userAgent)

class Loader

    constructor: (urls,cb)->
        finished=0
        completed = {}
        onComplete = (url,success,error=false)->
            finished += 1
            completed[url] = { success: success == true, error: error }
            cb(completed) if finished == urls.length

        this.head = document.querySelector('head')
        this.body = document.body

        _.each(urls, (url)->
          if /.css$/.test(url)
            this.loadCSS(url, onComplete)
          else
            this.loadJS(url, onComplete)
        ,this)


    loadCSS: (url, fn) ->
        getStylesheet = ->
          Array::filter.call(document.styleSheets, (stylesheet) ->
            stylesheet.ownerNode is node
          ).shift()
        poll = ->
          return  if called
          stylesheet = getStylesheet()
          return setTimeout(poll, 250)  if not stylesheet or not stylesheet.cssRules
          return setTimeout(poll, 250)  if not stylesheet or not stylesheet.rules or not stylesheet.rules.length
          called = true
          fn(url, true)
        exists = Array::some.call(document.styleSheets, (stylesheet) ->
          stylesheet.href is url
        )
        return fn(url, true)  if exists
        called = false
        tag = "link" #if GECKO then "style" else "link"
        node = _.el( tag,
           type: "text/css"
           href: url
           media: "screen"
           rel: "stylesheet"
        )

        onloaded=(success,err)->
            return if called
            called = true
            fn(url, success, err)
        node.onload  = ()->    onloaded(true,false)
        node.onerror = (err)-> onloaded(false,err)
        node.onreadystatechange = ->
            return if not (/loaded|complete/.test(node.readyState)) or called
            called=true
            fn(url, true)
        @head.appendChild node
        # GECKO cannot query the node immediatly after it's created
        if GECKO then _.delay(poll,250) else poll()



    loadJS: (url, fn) ->
        called = false
        node = _.el("script",
          type: "text/javascript"
          src: url
          charset: "utf-8"
          async: false
        )
        onloaded=(success,err)->
            return if called
            called = true
            fn(url, success, err)
        node.onload  = ()->    onloaded(true,false)
        node.onerror = (err)-> onloaded(false,err)

        node.onreadystatechange = ->
            return if not (/loaded|complete/.test(node.readyState)) or called
            called = true
            fn(url,true)
        this.body.appendChild(node)


Lanes.lib.Request = (urls...)->
    urls = urls[0] if urls.length == 1 && _.isArray(urls[0])
    new _.Promise(  (resolve,reject)->
        new Loader(urls, (completed)->
            failures = _.pick(completed, (status,url)-> !status.success )
            if _.isEmpty(failures)
                resolve(completed)
            else
                Lanes.warn( _.keys(failures).join(',') + " failed to load" )
                reject( failures )
        )
    )

##=require lanes/lib/namespace

Lanes.namespace('Remote')

Lanes.Remote.onDocumentReady = (fn) ->
    if document.readyState isnt 'loading'
        fn()
    else if document.addEventListener
        document.addEventListener 'DOMContentLoaded', fn
    else
        document.attachEvent 'onreadystatechange', ->
            fn() if document.readyState != 'loading'

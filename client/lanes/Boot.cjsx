Lanes.renderScreenTo = (selector, options) ->
    Lanes.config.bootstrap(options)
    document.addEventListener "DOMContentLoaded", ->
        viewport = new Lanes.React.Viewport({selector, options})

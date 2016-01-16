Lanes.renderScreenTo = (selector, options) ->
    Lanes.config.set(options)
    document.addEventListener "DOMContentLoaded", ->
        viewport = new Lanes.React.Viewport(selector: selector)
        Lanes.Models.PubSub.initialize()
        Lanes.Extensions.fireOnInitialized(viewport)
        Lanes.React.runRouter(viewport)
        Lanes.Extensions.fireOnAvailable(viewport)
        viewport.onBoot()

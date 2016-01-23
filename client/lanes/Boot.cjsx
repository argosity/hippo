Lanes.renderScreenTo = (selector, options) ->
    Lanes.config.bootstrap(options)
    document.addEventListener "DOMContentLoaded", ->
        viewport = new Lanes.React.Viewport(selector: selector)
        Lanes.Models.PubSub.initialize()
        Lanes.Extensions.fireOnInitialized(viewport)
        viewport.renderRoot()
        Lanes.Extensions.fireOnAvailable(viewport)
        viewport.onBoot()


class Lanes.Workspace.Layout extends Lanes.Views.Base

    template: 'workspace/layout'

    subviews:
        navbar:
            hook: 'navbar-container'
            view: 'Lanes.Workspace.Navbar'

        pages:
            hook: 'page-container'
            view: 'Lanes.Workspace.Pages'

    subviewOptions: -> { model: this.model }

    onRender: ->
        @screens = new Lanes.Workspace.ScreensMenu({ parent: this, model: @model })
        this.viewport.menu_view = @screens.render()

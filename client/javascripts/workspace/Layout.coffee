
class Lanes.Workspace.Layout extends Lanes.View.Base

    templateName: 'workspace/layout'

    subviews:
        navbar:
            hook: 'navbar-container'
            view: 'Lanes.Workspace.Navbar'
            model: 'model'
        pages:
            hook: 'page-container'
            view: 'Lanes.Workspace.Pages'
            model: 'model'

    onRender: ->
        @screens = new Lanes.Workspace.ScreensMenu({ parent: this, model: @model })
        this.ui.menu_view = @screens.render()

class Lanes.Workspace.Pages extends Lanes.Views.Base

    templateName: 'pages'
    FILE: FILE
    mixins:[
        Lanes.Workspace.WorkspaceView
    ]

    bindings:
        'model.layout_size': { selector: '.page-content', type: 'class' }
        'model.screen_menu_size': { type: 'class' }
        'model.popover_menu': { type: 'booleanClass', name: 'popover-menu' }


    subviews:
        menu:
            view: 'ScreensMenu'

    ui:
        screen: '.screen'


    initialize: (options)->
        this.listenTo( Lanes.Screens.Definitions.displaying, "change:active", this.onActiveChange )
        this.listenTo( Lanes.Screens.Definitions.displaying, "remove",        this.onRemove )
        #this.listenTo( @model,'change:screen_menu_position', this.moveScreensMenu )
        super

    # moveScreensMenu: ->
    #     return unless 'side' == this.viewport.screen_menu_position
    #     this.ui.screens_menu_container.append( this.viewport.menu_view.el )

    onRemove: (sv)->
        sv.view.remove()

    onActiveChange: (screen,active)->
        view = screen.view
        view.parent = this
        unless view.rendered
            view.render()

        if active
            this.ui.screen.append( view.el )
        else
            view.$el.detach()

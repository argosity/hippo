class Lanes.Workspace.Pages extends Lanes.Views.Base

    templateName: 'pages'
    FILE: FILE
    mixins:[
        Lanes.Workspace.WorkspaceView
    ]

    bindings:
        'model.screen_menu_size': { type: 'class' }
        'model.layout_size': { selector: '.page-content', type: 'class' }
        'screen_menu_class': { type: 'class' }

    derived:
        screen_menu_class:
            deps: ['model.screen_menu_position']
            fn: -> if @model.screen_menu_position == 'side' then 'with-screen-menu' else 'no-screen-menu'

    ui:
        screen: '.screen'
        screens_menu_container: '.screens-menu-container'

    initialize: (options)->
        this.listenTo( Lanes.Models.Screens.displaying, "change:active", this.onActiveChange )
        this.listenTo( Lanes.Models.Screens.displaying, "remove",        this.onRemove )
        this.listenTo( @model,'change:screen_menu_position', this.moveScreensMenu )
        super


    moveScreensMenu: ->
        return unless 'side' == this.viewport.screen_menu_position
        this.ui.screens_menu_container.append( this.viewport.menu_view.el )

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

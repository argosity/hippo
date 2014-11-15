class Lanes.Workspace.Pages extends Lanes.View.Base

    templateName: 'workspace/pages'

    bindings:
        'model.screen_menu_size': { type: 'class' }
        'model.layout_size': { selector: '.page-content', type: 'class' }
        'screen_menu_class': { type: 'class' }

    derived:
        screen_menu_class:
            deps: ['model.screen_menu_position']
            fn: -> if @model.screen_menu_position == 'side' then 'with-screen-menu' else 'no-screen-menu'


    initialize: (options)->
        this.listenTo( Lanes.Data.Screens.displaying, "change:active", this.onActiveChange )
        this.listenTo( Lanes.Data.Screens.displaying, "remove",        this.onRemove )
        this.listenTo( @model,'change:screen_menu_position', this.moveScreensMenu )
        super

    render: ->
        super
        this.cacheElements({
            screen: '.screen'
            screens_menu_container: '.screens-menu-container'
        })
        this

    moveScreensMenu: ->
        return unless 'side' == @ui.screen_menu_position
        this.screens_menu_container.appendChild( @ui.menu_view.el )

    onRemove: (sv)->
        sv.view.remove()

    onActiveChange: (screen,active)->
        view = screen.view
        view.parent = this
        unless view.rendered
            view.render()

        if active
            @screen.appendChild( view.el )
        else
            @screen.removeChild( view.el )

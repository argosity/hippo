

MENU_NARROW_WIDTH = 60
MENU_WIDE_WIDTH   = 250
NAVBAR_HEIGHT     = 50
BREAKPOINTS = {
    sm: 750
    md: 970
    lg: 1170
}

ALL_INSTANCES = []

class Lanes.Views.InterfaceState extends Lanes.Data.BasicModel

    constructor: ->
        super
        ALL_INSTANCES.push(this)

        this.on('change:root', =>
            @viewport_width = @root.width()
            @root.data()['ui']=@
        )
        this.on('change:menu_view', =>
            @trigger('change:screen_menu_position', @, @screen_menu_position )
        )
        this.on('change:menu_view', =>
            @trigger('change:screen_menu_position', @, @screen_menu_position )
        )
        this.screen_menu_shown = false if this.tiny_screen

    session:
        screen_menu_preference: {
            type: 'string',
            values: [ 'menu-wide', 'menu-narrow', 'menu-hidden' ]
        }
        root:              'element'
        menu_view:         'any'
        viewport:          'element'
        viewport_width:    'number'
        viewport_height:   'number'
        screen_menu_shown: 'boolean'
        http_error:        'string'
        selector:          'string'
        instance:          'object'

    derived:
        menu_width:
            deps: ['screen_menu_size'], fn: ->
                switch this.screen_menu_size
                    when 'menu-wide' then 240
                    when 'menu-narrow' then 60
                    else 0
        layout_size:
            deps: ['screens_width'], fn:->
                switch
                    when @screens_width < BREAKPOINTS.sm then 'tiny'
                    when @screens_width < BREAKPOINTS.md then 'sm'
                    when @screens_width < BREAKPOINTS.lg then 'md'
                    else 'lg'
        tiny_screen:
            deps: ['layout_size'], fn:->
                @layout_size == 'tiny'

        screen_menu_position:
            deps: ['viewport_width'], fn: ->
                if this.viewport_width < BREAKPOINTS.sm + MENU_NARROW_WIDTH then 'top' else 'side'

        screen_menu_size:
            deps: ['viewport_width','screen_menu_preference'], fn: ->
                return @screen_menu_preference if @screen_menu_preference
                width = this.viewport_width
                switch
                    when width < BREAKPOINTS.sm + MENU_NARROW_WIDTH then 'menu-hidden'
                    when width < BREAKPOINTS.lg + MENU_WIDE_WIDTH   then 'menu-narrow'
                    else 'menu-wide'
        screens_width:
            deps: ['viewport_width','screen_menu_size'], fn: ->
                @viewport_width - @menu_width

        screens_height:
            deps: ['viewport_height'], fn: ->
                @viewport_height - NAVBAR_HEIGHT

    nextSidebarState: ->
        if ! @screen_menu_preference
            @screen_menu_preference = @screen_menu_size
        this.toggle('screen_menu_preference')

MENU_NARROW_WIDTH = 60
MENU_WIDE_WIDTH   = 250
NAVBAR_HEIGHT     = 50
BREAKPOINTS = {
    sm: 750
    md: 970
    lg: 1170
}

class Lanes.Workspace.UIState extends Lanes.Models.State

    session:
        screen_menu_preference: {
            type: 'string',
            values: [ 'menu-wide', 'menu-narrow', 'menu-hidden' ]
        }
        root:      'element'
        menu_view: 'any'
        width:     'number'
        height:    'number'
        layout:    'state'
        viewport:  'object'
        screen_menu_shown: 'boolean'

    derived:
        menu_width:
            deps: ['screen_menu_size'], fn: ->
                switch this.screen_menu_size
                    when 'menu-wide' then 240
                    when 'menu-narrow' then 60
                    else 0

        layout_size:
            deps: ['screens_width'], fn: ->
                switch
                    when @screens_width < BREAKPOINTS.sm then 'xs'
                    when @screens_width < BREAKPOINTS.md then 'sm'
                    when @screens_width < BREAKPOINTS.lg then 'md'
                    else 'lg'

        popover_menu:
            deps: ['width'], fn: ->
                # same as the below menu-hidden value on screen_menu_size
                @width < BREAKPOINTS.md + MENU_NARROW_WIDTH

        screen_menu_size:
            deps: ['width', 'screen_menu_preference'], fn: ->
                return @screen_menu_preference if @screen_menu_preference
                switch
                    when @width < BREAKPOINTS.md + MENU_NARROW_WIDTH then 'menu-hidden'
                    when @width < BREAKPOINTS.lg + MENU_WIDE_WIDTH   then 'menu-narrow'
                    else 'menu-wide'

        screens_width:
            deps: ['width', 'screen_menu_size'], fn: ->
                @width - ( if @popover_menu then 0 else @menu_width )

        screens_height:
            deps: ['height'], fn: ->
                @height - NAVBAR_HEIGHT

    constructor:  ->
        super

    onBoot: (@viewport) ->
        this.listenToAndRun(@viewport, 'change:width change:height', @setSize)
        this.screen_menu_shown = false if this.tiny_screen

    setSize: ->
        this.set(_.pick(@viewport, 'width', 'height'))

    nextSidebarState: ->
        if ! @screen_menu_preference
            @screen_menu_preference = @screen_menu_size
        if @popover_menu
            @screen_menu_preference = if @screen_menu_preference == "menu-wide" then "menu-hidden" else "menu-wide"
        else
            this.toggle('screen_menu_preference')

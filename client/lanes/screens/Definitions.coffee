class ScreenView extends Lanes.Models.BasicModel

    session:
        screen: 'object'
        active: ['boolean', true, true]
        id: type: 'number', setOnce: true, required: true, default: ->
            _.uniqueId('screen')


    component: ->
        @screen.getScreen()

    initialize: (options) ->
        Lanes.Screens.Definitions.displaying.add( this )

    remove: ->
        Lanes.Screens.Definitions.displaying.remove( this )



class ScreenDefinition extends Lanes.Models.BasicModel

    session:
        id:          'string'
        title:       'string'
        url_prefix:  'string'
        description: 'string'
        view:        'string'
        icon:        'string'
        group_id:    'string'
        loading:     'boolean'
        extension:   'string'
        model:       'string'
        assets:      'array'
        js:          'string'
        css:         'string'

    derived:
        extension_ns:
            deps: ['extension'], fn: ->
                Lanes[_.classify(@extension)]

        model_type:
            deps: ['model'], fn: ->
                Lanes.u.getPath(@model) ||
                    Lanes.u.findObject(@model, "Models", namespace: Lanes[this.extension])
        asset_paths:
            deps: ['assets'], fn: ->
                prefix = if @url_prefix
                    @url_prefix
                else
                    "#{@extension.toLowerCase()}/screens"
                @assets.map (asset) -> "#{prefix}/#{asset}"

        extension_path:
            deps: ['extension', 'model'], fn: ->
                _.classify(@extension) + ".Screens." + @view

    _setDisplaying: ->
        new ScreenView( screen: this )

    getScreen: ->
        Lanes.u.getPath(@extension_path)

    ensureLoaded: ->
        if this.getScreen()
            _.Promise.resolve(this)
        else
            this.loadScreen()

    loadScreen: ->
        me = this
        return new _.Promise( (resolve, reject) ->
            me.loading = true
            Lanes.lib.RequestAssets(me.asset_paths...)
                .then ->
                    me.loading = false
                    viewModel = me.getScreen()
                    if viewModel then resolve(me)
                    else reject("Screen #{me.view} not definied after file retrieval")
                , (msg) ->
                    Lanes.warn(msg)
                    me.loading = false
                    reject(msg)
        )


    display: ->
        this.ensureLoaded().then =>
            @_setDisplaying()


class ScreenViewSet extends Lanes.Models.BasicCollection

    model: ScreenView

    active: ->
        @findWhere( active: true )

    initialize: (models, options = {}) ->
        this.on( 'change:active', this.onActiveChange )

    remove: (model) ->
        index = this.indexOf(model)
        super
        if model.active && this.length
            this.at(_.min([index, this.length - 1])).active = true
        model.active = false
        this

    onActiveChange: (changed, active) ->
        return unless active
        this.each (screen) ->
            screen.set( active: false ) unless screen == changed

    activateNext: -> this._moveActive(+1)
    activatePrev: -> this._moveActive(-1)

    _moveActive: (inc) ->
        return if this.length == 1
        current = this.findIndexWhere( active: true )
        return if current == -1
        if inc > 0 && current == this.length - 1
            current = -1
        if inc < 0 && current == 0
            current = this.length
        this.at(current + inc).active = true



class ScreenSet extends Lanes.Models.BasicCollection

    model: ScreenDefinition

    register: Lanes.emptyFn

    addScreen: (screen) ->
        screen = this.add( screen )
        screen.set(active:true)



class MenuGroup extends Lanes.Models.BasicModel

    session:
        id:          'string'
        title:       'string'
        description: 'string'
        icon:        'string'
        active:      ['boolean', true, false]

    constructor: ->
        super
        Lanes.current_user.on "change:isLoggedIn", => delete @cache

    screens: ->
        @cache ||= new Lanes.Models.SubCollection( Lanes.Screens.Definitions.all, {
            filter: (screen) =>
                screen.group_id == @id &&
                    (!screen.model_type || Lanes.current_user.canRead(screen.model_type))
            watched: ['group_id']
        })

class MenuGroupSet extends Lanes.Models.BasicCollection

    model: MenuGroup

    constructor: ->
        super
        Lanes.current_user.on("change:isLoggedIn", =>
            delete @cache
        )

    available: ->
        @cache ||= new Lanes.Models.SubCollection(this, {
            filter: (group) ->
                group.screens().filter()
                group.screens().length > 0
        })

Lanes.Screens.display_id = (screen_id) ->
    definition = Lanes.Screens.Definitions.all.get(screen_id)
    if (definition)
        definition.display()
    else
        Lanes.warn "Unable to find definition for screen #{screen_id}"

Lanes.Screens.Definitions = {
    all: new ScreenSet
    displaying: new ScreenViewSet([], { single_active_only: true })
    groups:  new MenuGroupSet
    register: (spec) ->
        this.all.add( spec )
}

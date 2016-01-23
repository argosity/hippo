class ScreenView extends Lanes.Models.BasicModel

    session:
        props:  'object'
        screen: 'object'
        active: ['boolean', true, true]
        id: type: 'string', setOnce: true, required: true, default: ->
            Math.random().toString(36).replace(/[^a-z]+/g, '').substr(0, 3);

    component: ->
        @screen.getScreen()

    initialize: (options) ->
        Lanes.Screens.Definitions.displaying.add( this )

    remove: ->
        Lanes.Screens.Definitions.displaying.remove( this )

    historyUrl: ->
        pathname: "/#{@screen.id}/#{@id}/"

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

        label:
            deps: ['id', 'title'], fn: ->
                @title || _.field2title(@id)

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
            attempt = 0
            done = ->
                me.loading = false
                viewModel = me.getScreen()
                if viewModel
                    resolve(me)
                else if attempt < 3
                    attempt += 1
                    _.delay(done, 500)
                else
                    reject("Screen #{me.view} not definied after file retrieval")
            err = (msg) ->
                Lanes.warn(msg)
                me.loading = false
                reject(msg)
            Lanes.lib.RequestAssets(me.asset_paths...).then(done, err)
        )


    display: (props) ->
        props = _.extend({}, props, screen: this)
        this.ensureLoaded().then -> new ScreenView(props)


class ScreenViewSet extends Lanes.Models.BasicCollection

    model: ScreenView

    active: ->
        @findWhere( active: true )

    initialize: (models, options = {}) ->
        Lanes.current_user.on "change:isLoggedIn", (user) =>
            if user.isLoggedIn
                for screen_id in Lanes.current_user.options?.initial_screens || []
                    Lanes.Screens.Definitions.all.get(screen_id)?.display()
            else
                @reset()
        this.on( 'change:active add', this.onActiveChange )

    remove: (model) ->
        index = this.indexOf(model)
        super
        if model.active && this.length
            this.at(_.min([index, this.length - 1])).active = true
        model.active = false
        this

    onActiveChange: (changed, active) ->
        return unless changed.active
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

    findInstance: (screenId, instanceId) ->
        this.find (instance) ->
            instance.screen.id is screenId and instance.id is instanceId

class ScreenSet extends Lanes.Models.BasicCollection

    model: ScreenDefinition

    register: Lanes.emptyFn

    addScreen: (screen) ->
        screen = this.add( screen )
        screen.set(active:true)

    isLoading: ->
        !!Lanes.Screens.Definitions.all.findWhere({loading: true})

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
    setBrowserLocation: (location) ->
        [screenId, instanceId, args...] = _.compact(location.pathname.split('/'))
        return unless screenId
        if instanceId and ( instance = @displaying.findInstance(screenId, instanceId) )
            instance.active = true
        else
            @all.get(screenId)?.display(id: instanceId, args: args)

}

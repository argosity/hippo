class SystemSettings extends Lanes.Models.Base

    mixins: [ Lanes.Models.Mixins.FileSupport ]

    props:
        id:       {type:"integer"}
        logo:     "file"
        settings: "object"

    modelTypeIdentifier: -> 'system-settings'
    url: -> Lanes.config.api_path + '/system-settings'
    initialize: ->
        @on('change:settings', @setDefaultSettings)
        @setDefaultSettings()

    setDefaultSettings: ->
        @settings ||= {}
        @settings.lanes || = {}

    forExtension: (ext) ->
        @settings[ext] ||= {}

    setValueForExtension: (ext, key, value) ->
        @forExtension(ext)[key] = value

class Config extends Lanes.Models.State

    session:
        csrf_token:  { type: 'string', setOnce: true }
        root_path:   { type: 'string', setOnce: true }
        api_path:    { type: 'string', setOnce: true }
        assets_path_prefix: { type: 'string', setOnce: true }
        environment: { type: 'string', setOnce: true }
        initial_workspace_screen_id: { type: 'string', setOnce: true }
        system_settings: { type: 'state', required: true }

    derived:
        env:
            deps: ['environment'], fn: ->
                {
                    test:        this.environment == 'test',
                    development: this.environment == 'development',
                    production:  this.environment == 'production'
                }

    initialize: ->
        @system_settings = new SystemSettings

    bootstrap: (options) ->
        if options.system_settings
            @system_settings.set(options.system_settings)
            delete options.system_settings
        @set(options)
        Lanes.Extensions.setBootstrapData(options) if _.isObject(options)

Lanes.config = new Config

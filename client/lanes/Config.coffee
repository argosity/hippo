class SystemSettings extends Lanes.Models.Base

    mixins: [ Lanes.Models.Mixins.FileSupport ]

    props:
        id:       {type:"integer"}
        settings: "object"

    associations:
        logo:        { model: "Lanes.Models.Asset"        }
        smtp:        { model: "Lanes.Models.SmtpSettings" }
        print_logo:  { model: "Lanes.Models.Asset"        }

    modelTypeIdentifier: -> 'system-settings'
    url: -> Lanes.config.api_path + '/system-settings'
    initialize: ->
        @on('change:settings', @setDefaultSettings)
        @smtp.set(@settings?.lanes?.smtp)
        @setDefaultSettings()

    setDefaultSettings: ->
        @settings ||= {}
        @settings.lanes ||= {}

    forExtension: (ext) ->
        @settings[ext] ||= {}

    setValueForExtension: (ext, key, value) ->
        @forExtension(ext)[key] = value

    set: (data) ->
        ret = super
        @smtp.set(@settings?.lanes?.smtp)
        ret

    dataForSave: ->
        data = super
        data.settings.lanes.smtp = @smtp.serialize()
        data

class Config extends Lanes.Models.State

    session:
        csrf_token:  { type: 'string', setOnce: true     }
        root_path:   { type: 'string', setOnce: true     }
        api_path:    { type: 'string', default: '/api'   }
        environment: { type: 'string', setOnce: true     }
        system_settings: { type: 'state', required: true }
        assets_path_prefix: { type: 'string', setOnce: true }
        api_host:    { type: 'string', default: "//#{window.location.host }" }
        initial_workspace_screen_id: { type: 'string', setOnce: true      }

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

configInstance = new Config

Object.defineProperty Lanes, 'config',
    get: -> configInstance
    set: -> throw new Error("Unable to reset config")

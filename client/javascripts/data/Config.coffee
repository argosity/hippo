class Config
    constructor: -> super

    session:
        csrf_token: { type: 'string', setOnce: false }
        api_path:   { type: 'string', setOnce: false }

    # derived:
    #     api_path:
    #         deps: ['root_path']
    #         fn: -> @root_path + "api"

Lanes.Data.State.extend(Config)

Lanes.Data.Config = new Config

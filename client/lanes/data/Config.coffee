class Config
    constructor: -> super

    session:
        csrf_token: { type: 'string', setOnce: false }
        api_path:   { type: 'string', setOnce: false }

Lanes.Data.State.extend(Config)

Lanes.Data.Config = new Config

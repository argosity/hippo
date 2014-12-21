class Config
    constructor: -> super

    session:
        csrf_token: { type: 'string', setOnce: false }
        api_path:   { type: 'string', setOnce: false }

Lanes.Models.State.extend(Config)

Lanes.Models.Config = new Config

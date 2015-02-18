class Config extends Lanes.Models.State
    constructor: -> super

    session:
        csrf_token:  { type: 'string', setOnce: true }
        api_path:    { type: 'string', setOnce: true }
        environment: { type: 'string', setOnce: true }

    derived:
        env:
            deps: ['environment'], fn: ->
                {
                    test:     this.environment == 'test',
                    development: this.environment == 'development',
                    production:  this.environment == 'production'
                }


Lanes.config = new Config

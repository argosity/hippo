class Config extends Lanes.Models.State

    session:
        csrf_token:  { type: 'string', setOnce: true }
        api_path:    { type: 'string', setOnce: true }
        assets_path_prefix: { type: 'string', setOnce: true }
        environment: { type: 'string', setOnce: true }
        initial_workspace_screen_id: { type: 'string', setOnce: true }

    derived:
        env:
            deps: ['environment'], fn: ->
                {
                    test:     this.environment == 'test',
                    development: this.environment == 'development',
                    production:  this.environment == 'production'
                }

Lanes.config = new Config

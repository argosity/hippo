class Lanes.Models.JobStatus extends Lanes.Models.Base

    props:
        id:          'string'
        job_name:    'string'
        progress:    'integer'
        attempt:     'integer'
        state:       'string'
        recorded_at: 'date'
        queued_at:   'date'
        errors:      'any'
        data:        'object'

    api_key: -> Lanes.config.api_path + '/job-status'
    events:
        'remote-update': 'onUpdate'

    derived:
        isSubmitted:
            deps: ['state'], fn: -> !!@state?
        isExecuting:
            deps: ['state'], fn: ->
                _.contains(['unqueued', 'queued', 'started'], @state)

    onUpdate: ->
        @parent?.trigger('update', @)

class Lanes.Models.JobStatus extends Lanes.Models.Base

    props:
        id:          'string'
        job_name:    'string'
        progress:    'number'
        attempt:     'integer'
        state:       'string'
        recorded_at: 'date'
        queued_at:   'date'
        errors:      'any'
        data:        'object'

    events:
        'remote-update': 'onUpdate'

    derived:
        isSubmitted:
            deps: ['id'], fn: -> !@isNew()
        isExecuting:
            deps: ['state'], fn: ->
                _.includes(['unqueued', 'queued', 'started'], @state)
        isActive:
            deps: ['isSubmitted', 'isExecuting'], fn: ->
                !(@isSubmitted or @isExecuting)
        stepsCompleted:
            deps: ['data'], fn: ->
                _.map(_.keys(@data?.output), _.titleize)

    onUpdate: ->
        @trigger('update', @)
        @parent?.trigger('update', @)

unless Lanes.Models.Role

    class Lanes.Models.Role extends Lanes.Models.Base
        props:
            id:     'string'
            name:   'string'
            member: { type: 'boolean', default: false }

unless Lanes.Models.User
    class Lanes.Models.User extends Lanes.Models.Base

        constructor: (attributes, access) ->
            super
            this.access_data = access

        api_path: -> 'users'

        derived:
            roles:
                fn: -> []
            isLoggedIn:
                fn: -> false
            allRoles:
                fn: -> new Lanes.Models.Role.Collection

        session:
            access_data: 'object'
            id:          'integer'
            login:       'string'
            name:        'string'
            email:       'string'
            role_names:  'array'
            options:     'object'
            password:    'string'

        canRead:   (model, field) -> true
        canWrite:  (model, field) -> true
        canDelete: (model)        -> true

CURRENT_USER = null

Object.defineProperty(Lanes, 'current_user', {

    set: (user) ->
        events = null
        if CURRENT_USER
            events = CURRENT_USER._events
        if _.some(events)
            for key, callbacks of events
                if user._events[key]
                    user._events[key] = user._events[key].concat(callbacks)
                else
                    user._events[key] = callbacks
        CURRENT_USER = user

    get: ->
        CURRENT_USER
})

Lanes.current_user = new Lanes.Models.User

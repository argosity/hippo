unless Lanes.Models.Roles

    class Lanes.Models.Role extends Lanes.Models.BasicModel
        props:
            id:     'string'
            name:   'string'
            member: { type: 'boolean', default: false }

    class Lanes.Models.Roles extends Lanes.Models.BasicCollection
        model: Lanes.Models.Role


unless Lanes.Models.User
    class Lanes.Models.User extends Lanes.Models.Base

        constructor: (attributes,access)->
            super
            this.access_data = access

        api_path: 'users'
        derived:
            roles:
                fn: -> []
            isLoggedIn:
                fn: -> false
            allRoles:
                fn: -> new Lanes.Models.Roles

        session:
            access_data: 'object'

        session:
            id:          "integer"
            login:       'string'
            name:        'string'
            email:       'string'
            role_names:  'array'
            options:     'object'
            password:    'string'

        canRead: (model,field)  -> true
        canWrite: (model,field) -> true
        canDelete: (model)      -> true

unless Lanes.current_user
    Lanes.current_user = new Lanes.Models.User

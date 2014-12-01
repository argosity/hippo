unless Lanes.Data.Roles

    class Lanes.Data.Role extends Lanes.Data.BasicModel
        props:
            id:     'string'
            name:   'string'
            member: { type: 'boolean', default: false }

    class Lanes.Data.Roles extends Lanes.Data.BasicCollection
        model: Lanes.Data.Role


unless Lanes.Data.User
    class Lanes.Data.User extends Lanes.Data.Model

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
                fn: -> new Lanes.Data.Roles

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
    Lanes.current_user = new Lanes.Data.User

class Lanes.Data.User extends Lanes.Data.Model

    constructor: (attributes,access)->
        super
        this.access_data = access

    api_path: 'users'
    derived:
        roles:
            deps: ['role_names', 'access_data']
            fn: -> new Lanes.Data.UserRoleSet( @access_data )
        isLoggedIn:
            deps:['id'], fn: -> !!this.id
        allRoles:
            deps: ['role_names', 'access_data']
            fn: ->
                role_data = Lanes.Data.Roles.all?.toJSON() || []
                roles = new Lanes.Data.Roles( role_data )
                _.each( this.role_names, (name)->
                    console.log name, roles
                    roles.get(name)?.member = true
                )
                roles

    session:
        access_data: 'object'

    props:
        id:         { type: "integer", required:true }
        login:       'string'
        name:        'string'
        email:       'string'
        role_names:  'array'
        options:     'object'
        password:    'string'

    canRead: (model,field)  -> this.roles.canRead(model,field)
    canWrite: (model,field) -> this.roles.canWrite(model,field)
    canDelete: (model)      -> this.roles.canDelete(model)

    logout: ->
        _.each(this.attributes, (value,key)=> @set(key, null) )

    setLoginData: (attrs, access)->
        this.access_data = access
        this.set(attrs)

    @attemptLogin: (login,password, options)->
        session = new Session( login: login, password: password )
        success = options.success
        session.save(_.extend(options,{
            success: (session)->
                Lanes.current_user.setLoginData(session.user, session.access)
                success.apply(options.scope, arguments)
        }))

Lanes.current_user = new Lanes.Data.User

class Lanes.Data.User.Collection extends Lanes.Data.Collection
    model: Lanes.Data.User


class Session extends Lanes.Data.Model
    api_path: 'user-session'
    props:
        id:         'integer'
        login:      'string'
        password:   'string'
        access:     'object'
        user:       'object'

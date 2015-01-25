class Role extends Lanes.Models.BasicModel
    props:
        id:     'string'
        name:   'string'
        member: { type: 'boolean', default: false }


class Lanes.Models.Roles extends Lanes.Models.BasicCollection
    model: Role
    comparator: 'name'




class UserRole
    constructor: (config={})->
        @type = config.type
        for method in RWD
            this[method] = _.map(config[method],klassFor)

    can: (type,model)->
        -1 != this[type].indexOf(model)


RWD = ['read','write','delete']

RoleMap = {
    administrator: Administrator
}

# The admin is special and can do anything
class Administrator
    constructor: ->
        UserRole.prototype.constructor.apply(this,arguments)
    can: -> true



class Lanes.Models.UserRoleSet

    constructor: (access={})->
        _.defaults(access, { roles: [], locked_fields: [] })
        @roles = []
        for role in access.roles
            klass = RoleMap[role.type] || UserRole
            @roles.push( new klass(role) )
        @locked_fields = {}
        for lock in access.locked_fields
            if klass = klassFor(lock.type)
                @locked_fields[ klass ] = locks = {}
                locks[field] = grants for field, grants of lock.locks

    can:(method,model,field)->
        if model instanceof Lanes.Models.Base
            model = model.constructor

        if field && ( locks = @locked_fields[model] ) && ( grants = locks[field] )
            for grant in grants
                if grant.only && grant.only != method
                    return this.testModelAccess(method,model)
                else
                    for role in @roles
                        return true if role.type == grant.role
            return false
        else
            return this.testModelAccess(method,model)

    testModelAccess:(method,model)->
        !!_.detect( @roles, (role)->role.can(method,model) )

    canRead:(model,field)->
        this.can('read',model,field)

    canWrite:(model,field)->
        this.can('write',model,field)

    canDelete:(model)->
        this.can('delete',model)

klassFor = (identifier)->
    name = _.classify(identifier)
    Lanes.Models[name] ||
        Lanes.warn("Role Data object not found for #{identifier}")

class Lanes.Access.Extension extends Lanes.Extensions.Base

    identifier: "lanes-access"

    setBootstrapData: (data)->
        Lanes.current_user = new Lanes.Models.User

        Lanes.Models.Roles.all = new Lanes.Models.Roles(
            _.map( data.roles, (role)->
                { id: role.toLowerCase(), name: role }
            )
        )
        if data.user
            Lanes.current_user.set(data.user)
        if data.access
            Lanes.current_user.access_data = data.access

    onAvailable: (view)->
        this.login_dialog = new Lanes.Access.LoginDialog({ parent: view })

        # screen=Lanes.Models.Screens.all.get("user-management")
        # screen.display(view.viewport)

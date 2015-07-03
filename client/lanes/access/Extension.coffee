class Lanes.Access.Extension extends Lanes.Extensions.Base

    identifier: "lanes-access"

    setBootstrapData: (data) ->
        Lanes.Models.Role.all = new Lanes.Models.Role.Collection( data.roles )
        Lanes.current_user = new Lanes.Models.User
        if data.user
            Lanes.current_user.set(data.user)
        if data.access
            Lanes.current_user.access_data = data.access

    showLogin: ->
        Lanes.Workspace.Extension.uistate.modalDialog = Lanes.Access.LoginDialog.instance()

    hideLogin: ->
        Lanes.Workspace.Extension.uistate.modalDialog = null

    onAvailable: (viewport) ->
        @viewport = viewport
        Lanes.current_user.on('change:isLoggedIn', =>
            if Lanes.current_user.isLoggedIn
                @hideLogin()
            else
                @showLogin()
        )
        unless Lanes.current_user.isLoggedIn
            @showLogin()

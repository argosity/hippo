class Lanes.Workspace.Extension extends Lanes.Extensions.Base

    identifier: "lanes-workspace"

    setBootstrapData: (data) ->
        Lanes.Workspace.Extension.uistate = new Lanes.Workspace.UIState

    onAvailable: (viewport) ->
        Lanes.Workspace.Extension.uistate.onBoot(viewport)
        for screen_id in Lanes.current_user.options?.initial_screens || []
            Lanes.Screens.Definitions.all.get(screen_id)?.display()

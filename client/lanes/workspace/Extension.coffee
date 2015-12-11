class Lanes.Workspace.Extension extends Lanes.Extensions.Base

    identifier: "lanes-workspace"

    setBootstrapData: (data) ->
        Lanes.Workspace.Extension.uistate = new Lanes.Workspace.UIState

    onAvailable: (viewport) ->
        Lanes.Workspace.Extension.uistate.onBoot(viewport)

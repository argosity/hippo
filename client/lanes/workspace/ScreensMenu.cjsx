class ScreenList extends Lanes.React.Component

    activateScreen: ->
        @model.display()

    render: ->
        <li>
            <a href="#" onClick={@activateScreen}>
                <span>{@model.title}</span><LC.Icon type={@model.icon} />
            </a>
        </li>


class ScreenGroup extends Lanes.React.Component

    toggleActive: ->
        @model.active = !@model.active
        undefined

    render: ->
        screens = @model.screens().map (list) ->
            <ScreenList model=list key=list.id />

        <li className={_.classnames("group", active: @model.active)} onClick={@toggleActive}>
            <a className="heading" href="#">
                <span>{@model.title}</span><i className={"icon icon-#{@model.icon}"}></i>
            </a>
            <ul>{screens}</ul>
        </li>

class Lanes.Workspace.ScreensMenu extends Lanes.React.Component

    dataObjects:
        user: -> Lanes.current_user

    renderGroup: (group) ->
        <ScreenGroup model=group key=group.id />

    logOut: ->
        Lanes.current_user.logout()

    render: ->
        <div className="screens-menu">
            <div className="screens-menu-content">
                <ul className="navigation">
                    {Lanes.Screens.Definitions.groups.available().map @renderGroup}
                </ul>
            </div>
            <ul className="navigation">
                <li className="group logout" data-tooltip-message="Log Out" data-placement="right">
                    <a href="#" name="LogOut" onClick={@logOut}>
                        <span>Log Out</span>
                        <LC.Icon type='times' />
                    </a>
                </li>
            </ul>
        </div>

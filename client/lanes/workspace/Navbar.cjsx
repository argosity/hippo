class Lanes.Workspace.Navbar extends Lanes.React.Component

    propTypes:
        history: React.PropTypes.shape(
            push: React.PropTypes.func
        ).isRequired

    contextTypes:
        uistate: React.PropTypes.object.isRequired

    switchMenu: ->
        @context.uistate.nextSidebarState()

    classNames: ->
        _.classnames 'header-top', @model.screen_menu_preference,
            "menu-hidden": !@model.screen_menu_shown

    render: ->
        <div className="header-top">
            <div className="navbar-header">
                <a className="navbar-brand logo" href="#">
                    Lanes
                </a>
                <button className="screens-menu-toggle" onClick={@switchMenu} type="button">
                    <span className="sr-only">Toggle navbar</span>
                    <i className="icon"></i>
                </button>
            </div>
            <Lanes.Workspace.Tabs history={@props.history} />
        </div>

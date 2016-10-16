class Lanes.Workspace.Navbar extends Lanes.React.Component
    modelBindings:
        settings: -> Lanes.config.system_settings

    contextTypes:
        uistate: React.PropTypes.object.isRequired

    switchMenu: ->
        @context.uistate.nextSidebarState()

    classNames: ->
        _.classnames 'header-top', @model.screen_menu_preference,
            "menu-hidden": !@model.screen_menu_shown

    Logo: ->
        if @settings.logo?.url
            url = "//#{Lanes.config.api_host}#{@settings.logo.thumbnail_url}"
            <img src={url} />
        else
            <span>
                {Lanes.Extensions.controlling().title()}
            </span>

    render: ->

        <div className="header-top">
            <div className="navbar-header">
                <a className="navbar-brand logo" href="#">
                    <@Logo />
                </a>
                <button className="screens-menu-toggle" onClick={@switchMenu} type="button">
                    <span className="sr-only">Toggle navbar</span>
                    <i className="icon"></i>
                </button>
            </div>
            <Lanes.Workspace.Tabs />
        </div>

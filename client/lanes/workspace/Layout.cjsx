class Lanes.Workspace.Layout extends Lanes.React.Component

    dataObjects:
        uistate: -> Lanes.Workspace.Extension.uistate

    childContextTypes:
        uistate:  Lanes.PropTypes.State

    getChildContext: ->
        uistate: @uistate

    componentWillMount: ->
        @uistate.set(@props)

    pageClasses: ->
        _.classnames( 'page-container', @uistate.screen_menu_size,
            {"popover_menu": @uistate.popover_menu}
        )

    render: ->
        <div className="layout">
            {@uistate.modalDialog?()}
            <Lanes.Workspace.Navbar/>
            <div className={@pageClasses()}>
                <Lanes.Workspace.ScreensMenu/>
                <Lanes.Workspace.ScreenView/>
            </div>
        </div>

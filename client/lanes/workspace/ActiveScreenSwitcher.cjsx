class TabView extends Lanes.React.Component

    activate: ->
        @model.active = true
        null

    close: ->
        @model.remove()

    render: ->
        <li key={@model.cid} className={_.classnames(active: @model.active)}>
            <a onClick={@activate} className='tab'>{@model.screen.title}</a>
            <span onClick={@close} className='close'>×</span>
        </li>


class Lanes.Workspace.ActiveScreenSwitcher extends Lanes.React.Component

    dataObjects:
        collection: -> Lanes.Screens.Definitions.displaying
        allScreens: -> Lanes.Screens.Definitions.all

    bindDataEvents: ->
        allScreens: 'change:loading'

    renderLoading: ->
        screen = Lanes.Screens.Definitions.all.findWhere(loading: true)
        <LC.NetworkActivityOverlay isRequesting message="Loading #{screen.title}…" />

    render: ->
        <div className="menu-container">
            {@renderLoading() if Lanes.Screens.Definitions.all.isLoading()}
            <div className="active-screens">
                <div className="scroller scroller-left">
                    <i className="glyphicon glyphicon-chevron-left"/>
                </div>
                <div className="scroller scroller-right">
                    <i className="glyphicon glyphicon-chevron-right"/>
                </div>
                <div className="wrapper">
                    <ul className="nav nav-tabs">
                        { @collection.map (view) ->
                            <TabView key={view.id} model=view /> }
                    </ul>
                </div>
            </div>
        </div>

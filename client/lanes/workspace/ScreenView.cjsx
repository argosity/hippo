Screen = React.createClass

    shouldComponentUpdate: ->
        false

    render: ->
        React.createElement(@props.component)

class Lanes.Workspace.ScreenView extends Lanes.React.Component
    contextTypes:
        uistate: React.PropTypes.object.isRequired

    dataObjects:
        displaying: -> Lanes.Screens.Definitions.displaying
        allScreens: -> Lanes.Screens.Definitions.all

    bindDataEvents:
        displaying: 'change:active remove add'
        allScreens: 'change:loading'

    renderScreen: (screen) ->
        <div key={screen.id} className={_.classnames("screen", active:screen.active)}>
            <Screen component={screen.component()} />
        </div>

    renderLoading: ->
        screen = Lanes.Screens.Definitions.all.findWhere(loading: true)
        <LC.NetworkActivityOverlay isRequesting message="Loading #{screen.title}…" />

    render: ->
        <div className={"page-content #{@context.uistate.layout_size}"}>
            {@renderLoading() if Lanes.Screens.Definitions.all.isLoading()}
            {@displaying.map @renderScreen}
        </div>

Screen = React.createClass

    displayName: 'Screen'
    shouldComponentUpdate: ->
        false
    render: ->
        React.createElement(@props.screen.component(), @props.screen.props)

class Lanes.Workspace.ScreenView extends Lanes.React.Component
    contextTypes:
        uistate: React.PropTypes.object.isRequired

    modelBindings:
        displaying: -> Lanes.Screens.Definitions.displaying
        allScreens: -> Lanes.Screens.Definitions.all

    bindEvents:
        displaying: 'change:active remove add'
        allScreens: 'change:loading'

    renderScreen: (screen) ->
        <div key={screen.id} className={_.classnames("screen", active:screen.active)}>
            <Screen screen={screen} />
        </div>

    renderLoading: ->
        screen = Lanes.Screens.Definitions.all.findWhere(loading: true)
        <LC.NetworkActivityOverlay visible model={screen} message="Loading #{screen.title}…" />

    BaseView: ->
        Base = Lanes.Extensions.controlling().initialScreen?() or Lanes.Workspace.FirstRun
        <div className="screen active base">
            <Base />
        </div>

    render: ->

        child = if @displaying.isEmpty() then <@BaseView /> else @displaying.map(@renderScreen)
        <div className={"page-content #{@context.uistate.layout_size}"}>
            {@renderLoading() if Lanes.Screens.Definitions.all.isLoading()}
            {child}
        </div>

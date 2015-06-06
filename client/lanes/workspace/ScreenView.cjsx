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

    bindDataEvents:
        displaying: 'change:active remove add'

    renderScreen: (screen) ->
        <div key={screen.id} className={_.classnames("screen", active:screen.active)}>
            <Screen component={screen.component()} />
        </div>

    render: ->
        <div className={"page-content #{@context.uistate.layout_size}"}>
            {@displaying.map @renderScreen}
        </div>

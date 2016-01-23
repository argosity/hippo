class TabView extends Lanes.React.Component
    propTypes:
        history: React.PropTypes.shape(
            push: React.PropTypes.func
        ).isRequired

    activate: ->
        @props.history.push(@model.historyState())
        #@model.active = true
        null

    close: ->
        @model.remove()

    render: ->
        <li key={@model.cid} className={_.classnames(active: @model.active)}>
            <a onClick={@activate} className='tab'>{@model.screen.title}</a>
            <span onClick={@close} className='close'>×</span>
        </li>


class Lanes.Workspace.Tabs extends Lanes.React.Component
    propTypes:
        history: React.PropTypes.shape(
            push: React.PropTypes.func
        ).isRequired

    dataObjects:
        collection: -> Lanes.Screens.Definitions.displaying

    render: ->
        <div className="menu-container">
            <div className="active-screens">
                <div className="scroller scroller-left">
                    <i className="glyphicon glyphicon-chevron-left"/>
                </div>
                <div className="scroller scroller-right">
                    <i className="glyphicon glyphicon-chevron-right"/>
                </div>
                <div className="wrapper">
                    <ul className="nav nav-tabs">
                        { @collection.map (view) =>
                            <TabView {...@props} key={view.id} model=view /> }
                    </ul>
                </div>
            </div>
        </div>
class TabView extends Lanes.React.Component

    setModelState: (nextState) ->
        if @model.active
            _.dom(document.head).qs('title').text = @model.title()
            @context.viewport.history.replace(@model.historyUrl())
        if Lanes.Screens.Definitions.displaying.length is 0
            @context.viewport.history.push('/')
        @setState(nextState)

    activate: ->
        @model.active = true
        @context.viewport.history.push(@model.historyUrl())
        null

    close: -> @model.remove()

    render: ->
        <li key={@model.cid} className={_.classnames(active: @model.active)}>
            <a onClick={@activate} className='tab'>{@model.title()}</a>
            <LC.Icon type={@model.screen.icon} />
            <span onClick={@close} className='close'>×</span>
        </li>


class Lanes.Workspace.Tabs extends Lanes.React.Component

    modelBindings:
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

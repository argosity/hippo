class Lanes.Components.PanelHeader extends Lanes.React.BaseComponent

    render: ->
        <div className="lanes-panel-heading">
            <h3 className="panel-title">{@props.title}</h3>
            <div className="spacer" />
            {@props.children}
        </div>

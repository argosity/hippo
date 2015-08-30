class Lanes.Components.ResizeSensor extends Lanes.React.BaseComponent

    propTypes:
        onResize: React.PropTypes.func.isRequired

    render: ->
        <Lanes.Vendor.ComponentResize
            {...@props}
            embedCss={false}
            className={_.classnames('lanes-resize-sensor', @props.className)}
        >{@props.children}</Lanes.Vendor.ComponentResize>

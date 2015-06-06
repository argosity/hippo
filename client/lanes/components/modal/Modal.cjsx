class Lanes.Components.Modal extends Lanes.React.Component

    contextTypes:
        uistate: Lanes.PropTypes.State.isRequired

    dataObjects: ->
        model: ->
            @context.uistate

    bindDataEvents: ->
        model: "change:width"

    componentWillUnmount: ->
        @context.uistate.modalDialog = null

    propTypes:
        title: React.PropTypes.node,
        backdrop: React.PropTypes.oneOf(['static', true, false]),
        keyboard: React.PropTypes.bool,
        closeButton: React.PropTypes.bool,
        animation: React.PropTypes.bool,
        onRequestHide: React.PropTypes.func

    onRequestHide: ->
        @context.uistate.modalDialog = null

    render: ->
        <BS.Modal
            className={@context.uistate.layout_size}
            bsSize="large"
            onRequestHide={@onRequestHide}
            {...@props} >

            {@props.children}

        </BS.Modal>

Lanes.React.Mixins.Viewport = {

    contextTypes:
        viewport: Lanes.PropTypes.State

    showDialog: (props) ->
        new Promise( (onOk, onCancel) =>
            @context.viewport.modalProps = _.extend({}, props, {show: true, onOk, onCancel})
        )

    hideDialog: ->
        @context.viewport.modal = {show: false}

}

Object.defineProperty Lanes.React.Mixins.Viewport, 'viewport',
    get: -> @context.viewport

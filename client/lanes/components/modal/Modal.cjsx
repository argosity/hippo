class Lanes.Components.Modal extends Lanes.React.Component

    propTypes:
        title:     React.PropTypes.string
        onOk:      React.PropTypes.func
        onCancel:  React.PropTypes.func
        body:      React.PropTypes.element
        show:      React.PropTypes.bool
        buttons:   React.PropTypes.array
        className: React.PropTypes.string
        size:      React.PropTypes.string

    contextTypes:
        viewport: Lanes.PropTypes.State
        uistate:  Lanes.PropTypes.State

    getDefaultProps: ->
        size: 'large'
        buttons: [
            { title: 'Cancel' }
            { title: 'OK', style: 'primary' }
        ]

    getInitialState: ->
        show: false

    onButton: (btn) ->
        @selected = btn
        if btn.eventKey is 'ok'
            @props.onOk?(this)
        else
            @props.onCancel?(this)
        @_hide()

    componentWillReceiveProps: (nextProps) ->
        @setState(show: nextProps.show) if nextProps.show?

    _hide: ->
        @context.viewport.modalProps.show = false
        @setState(show: false)

    hide: ->
        @_hide()
        @props.onCancel()

    render: ->
        return null unless @state.show

        buttons = for button in @props.buttons
            if _.isString(button) then button = {title: button}
            button.eventKey ||= (button.key or button.title).toLowerCase()
            <BS.Button key={button.title}
                bsStyle={button.style || 'default'} className={name}
                onClick={_.partial(@onButton, button)}>{button.title}</BS.Button>

        cls = _.classnames('lanes-dialog', @props.className, @context.uistate?.layout_size)

        <BS.Modal.Dialog className={cls} bsSize={@props.size} onHide={@_hide}>
            <BS.Modal.Header>
                <BS.Modal.Title>{@props.title}</BS.Modal.Title>
            </BS.Modal.Header>

            <BS.Modal.Body>{@props.body}</BS.Modal.Body>

            <BS.Modal.Footer>{buttons}</BS.Modal.Footer>

        </BS.Modal.Dialog>

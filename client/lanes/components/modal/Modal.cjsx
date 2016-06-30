class Lanes.Components.Modal extends Lanes.React.Component

    propTypes:
        title:     React.PropTypes.string
        onOk:      React.PropTypes.func
        onCancel:  React.PropTypes.func
        body:      React.PropTypes.func
        show:      React.PropTypes.bool
        buttons:   React.PropTypes.array
        autoHide:  React.PropTypes.bool
        className: React.PropTypes.string
        size:      React.PropTypes.string

    contextTypes:
        viewport: Lanes.PropTypes.State
        uistate:  Lanes.PropTypes.State

    getDefaultProps: ->
        size: 'large', autoHide: false
        buttons: [
            { title: 'Cancel' }
            { title: 'OK', style: 'primary' }
        ]

    getInitialState: ->
        show: false

    onOkButton: (ev) -> @state.onOk?(this, ev)
    onCancelButton: (ev) -> @state.onCancel?(this, ev)
    onButton: (ev, btn) ->
        @selected = btn
        if btn.eventKey is 'ok'
            @onOkButton(ev)
        else
            @onCancelButton(ev)
        @_hide() if @state.autoHide and ev.defaultPrevented isnt true

    componentWillReceiveProps: (nextProps) ->
        @replaceState(nextProps)

    _hide: ->
        @context.viewport.modalProps.show = false
        @setState(show: false)

    show: ->
        @context.viewport.modalProps.show = true
        @setState(show: true)

    hide: -> @_hide()

    render: ->
        return null unless @state.show

        buttons = for button in @state.buttons
            if _.isString(button) then button = {title: button}
            button.eventKey ||= (button.key or button.title).toLowerCase()
            <BS.Button key={button.title}
                bsStyle={button.style || 'default'} className={name}
                onClick={_.partial(@onButton, _, button)}>{button.title}</BS.Button>

        cls = _.classnames('lanes-modal', @state.className, @context.uistate?.layout_size)
        Body = @state.body
        <BS.Modal.Dialog className={cls} bsSize={@state.size} onHide={@_hide}>
            <BS.Modal.Header>
                <BS.Modal.Title>{@state.title}</BS.Modal.Title>
            </BS.Modal.Header>

            <BS.Modal.Body style={maxHeight: @context.viewport.height - 250}>
                <Body ref="body" {...@props} modal={@} />
            </BS.Modal.Body>

            <BS.Modal.Footer>{buttons}</BS.Modal.Footer>

        </BS.Modal.Dialog>

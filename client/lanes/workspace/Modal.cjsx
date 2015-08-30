# This is the "real" dialog component. It's rendered to a div under document.body
class Lanes.Workspace.Dialog extends Lanes.React.Component

    propTypes:
        title:     React.PropTypes.string.isRequired
        onOk:      React.PropTypes.func.isRequired
        onCancel:  React.PropTypes.func.isRequired
        body:      React.PropTypes.element.isRequired
        show:      React.PropTypes.bool
        buttons:   React.PropTypes.object
        className: React.PropTypes.string

    getDefaultProps: ->
        buttons: {'Cancel': 'default', 'OK': 'primary'}

    getInitialState: ->
        show: true

    componentWillReceiveProps: (nextProps) ->
        @setState(show: nextProps.show) if nextProps.show?

    _hide: ->
        @setState(show: false)

    hide: ->
        @_hide()
        @props.onCancel()

    render: ->
        return null unless @state.show

        buttons = for name, style of @props.buttons
            <BS.Button key={name} className={name}
              onClick={_.partial(@props.onButton, name)}>{name}</BS.Button>

        classes = _.classnames('layout-dialog', @props.className)

        <BS.Modal.Dialog>
            <BS.Modal.Header>
                <BS.Modal.Title>{@props.title}</BS.Modal.Title>
            </BS.Modal.Header>

            <BS.Modal.Body>{@props.body}</BS.Modal.Body>

            <BS.Modal.Footer>{@buttons}</BS.Modal.Footer>

        </BS.Modal.Dialog>

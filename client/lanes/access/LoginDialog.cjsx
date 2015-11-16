class Session extends Lanes.Models.Base
    api_path: 'user-session'
    props:
        id:         'integer'
        login:      'string'
        password:   'string'
        access:     'object'
        user:       'object'


class Lanes.Access.LoginDialog extends Lanes.React.Component

    statics:
        show: (viewport, props = {}) ->
            session = new Session
            handler = new _.Promise( (onOk, onCancel) ->
                viewport.modalProps = _.extend({}, props,
                    title: 'Please Login'
                    onCancel: onCancel, onOk: onOk, show: true,
                    buttons: [{ title: 'Ok', style: 'primary'}]
                    body: ->
                        <Lanes.Access.LoginDialog model={session} attemptLogin={onOk} />
                )
            )
            handler.then (dlg) ->
                session.save(ignoreErrors: true).then ->
                    if session.user
                        Lanes.current_user.setLoginData(session.user, session.access)
                    _.extend(viewport.modalProps, {show: !session.user})

    mixins: [
        Lanes.React.Mixins.RelayEditingState
    ]
    listenNetworkEvents: true

    getDefaultProps: ->
        writable: true, editOnly: true

    dataObjects: ->
        model: 'props'

    warning: ->
        <BS.Alert bsStyle='warning'>
            <strong>{@model.lastServerMessage}</strong>
        </BS.Alert>

    render: ->
        <div>
            {@warning() if @state?.hasError}
            <BS.Row>
                <BS.Col mdOffset={2} xs={12} md={8}>

                    <LC.Input
                        model={@model}
                        onEnter={@props.attemptLogin}
                        autoFocus writable
                        name="login"
                        label='Username'
                        placeholder='Enter Login'
                    />

                    <LC.Input
                        writable
                        model={@model}
                        onEnter={@props.attemptLogin}
                        name="password"
                        type='password'
                        label='Password'
                        placeholder='Enter Password'
                    />

                </BS.Col>
            </BS.Row>
        </div>



# Function that returns a factory (or function) for the LoginDialog.
# Intended as an extension point for other users to override if needed
Lanes.Access.LoginDialog.instance = ->
    Lanes.Access.LoginDialog

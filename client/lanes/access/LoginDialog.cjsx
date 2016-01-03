class Session extends Lanes.Models.Base
    api_path: 'lanes-access/user-session'

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

            attemptLogin = (dlg) ->
                session.save(ignoreErrors: true).then ->
                    if session.user
                        Lanes.current_user.setLoginData(session.user, session.access)
                        dlg.hide()
                    _.extend(viewport.modalProps, {show: !session.user})

            viewport.modalProps = _.extend({}, props,
                title: 'Please Login'
                onCancel: null, onOk: attemptLogin, show: true,
                buttons: [{ title: 'Login', style: 'primary', eventKey: 'ok'}]
                body: (props) ->
                    <Lanes.Access.LoginDialog
                        {...props}
                        model={session}
                        attemptLogin={attemptLogin} />
            )



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
                        onEnter={=> @props.attemptLogin(@props.modal)}
                        autoFocus writable
                        name="login"
                        label='Username'
                        placeholder='Enter Login'
                    />

                    <LC.Input
                        writable
                        model={@model}
                        onEnter={=> @props.attemptLogin(@props.modal)}
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

class Session extends Lanes.Models.Base
    api_path: 'user-session'
    props:
        id:         'integer'
        login:      'string'
        password:   'string'
        access:     'object'
        user:       'object'


class Lanes.Access.LoginDialog extends Lanes.React.Component

    mixins: [
        Lanes.React.Mixins.RelayEditingState
    ]

    getDefaultProps: ->
        writable: true, editOnly: true

    dataObjects: ->
        model: new Session

    login: ->
        @model.save().then =>
            Lanes.current_user.setLoginData(@model.user, @model.access) if @model.user

    warning: ->
        <BS.Alert bsStyle='warning'>
             <strong>{@model.lastServerMessage}</strong>
        </BS.Alert>

    render: ->
        <LC.Modal title='Please log in'
            backdrop={false}
            closeButton=false
            animation={false}>

            <div className='modal-body'>

                {@warning() if @state?.hasError}

                <BS.Row>
                    <BS.Col mdOffset={2} xs={12} md={8}>

                        <LC.TextField
                            model={@model}
                            autoFocus writable
                            name="login"
                            label='Username'
                            placeholder='Enter Login'
                        />

                        <LC.TextField
                            writable
                            model={@model}
                            name="password"
                            type='password'
                            label='Password'
                            placeholder='Enter Password'
                        />

                    </BS.Col>
                </BS.Row>
            </div>


            <div className='modal-footer'>
                <BS.Button onClick={@login} bsStyle='primary'>Login</BS.Button>
            </div>

        </LC.Modal>



# Function that returns a factory (or function) for the LoginDialog.
# Intended as an extension point for other users to override if needed
Lanes.Access.LoginDialog.instance = ->
    @cache ||= React.createFactory(Lanes.Access.LoginDialog)

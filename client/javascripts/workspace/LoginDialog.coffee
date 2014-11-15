class Lanes.View.LoginDialog extends Lanes.Component.ModalDialog

    bodyTemplateName: 'workspace/login-dialog'
    size: 'md'
    title: 'Please sign in …'

    events:
        'click .btn-primary': 'onLogin'

    buttons:
        login: { label: 'Login', type: 'primary' }

    initialize: (options)->
        super
        this.listenTo(Lanes.current_user, 'change:isLoggedIn', this.onUserChange)
        this.onUserChange()

    onUserChange: ->
        this.toggleShown(!Lanes.current_user.isLoggedIn)

    onLogin: (ev)->
        msg = this.$('.alert').hide()
        mask = new Lanes.View.TimedMask(this.$el, "Attempting Login …")
        Lanes.Data.User.attemptLogin( this.query('#LoginField').value, this.query('#PasswordField').value, {
            scope: this
            success: ->
                mask.displaySuccess("Login Success!")
            error: (session,reply)->
                msg.show().text(session.lastServerMessage )
                mask.displayFailure(session.lastServerMessage)
        })

    onShown: -> this.query('.login').focus()

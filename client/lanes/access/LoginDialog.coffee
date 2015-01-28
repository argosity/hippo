class Lanes.Access.LoginDialog extends Lanes.Components.ModalDialog

    bodyTemplateName: 'login-dialog'
    templatePrefix: 'lanes/access'
    hideOnBackdropClick: false
    showHideButton: false
    hideOnEsc: false

    size: 'md'
    title: 'Please sign in …'
    FILE: FILE

    domEvents:
        'click .btn-primary': 'onLogin'

    buttons:
        login: { label: 'Login', type: 'primary' }

    ui:
        l: '#LoginField',
        pw: '#PasswordField'
        alert: '.alert'

    initialize: (options)->
        super
        this.listenToAndRun(Lanes.current_user, 'change:isLoggedIn', this.onUserChange)

    onUserChange: ->
        this.toggleShown(!Lanes.current_user.isLoggedIn)

    onLogin: (ev)->
        msg = this.ui.alert.hide()
        mask = new Lanes.Views.TimedMask(this.$el, "Attempting Login …")
        session = Lanes.Models.User.attemptLogin( @ui.l.val(), @ui.pw.val(), {
            scope: this
            success: ->
                mask.displaySuccess("Login Success!")
            error: ->
                msg.show().text(session.lastServerMessage )
                mask.displayFailure(session.lastServerMessage)
        })

    onShown: -> @ui.l.focus()


Lanes.Access.createLoginDialog = (view)->
    new Lanes.Access.LoginDialog( parent: view )

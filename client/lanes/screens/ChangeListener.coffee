Lanes.Screens.ChangeListener = {

    modelEvents:
        'remote-update': 'onChange'

    domEvents:
        'show.bs.dropdown .changes-notification': 'onChangesShow'

    session:
        change_count: ['number', true, 0]

    derived:
        changes: deps:[], fn: ->
            new Lanes.Models.ChangeSetCollection([],{ parent: this })
        changes_visible: { deps: ['change_count'], fn:-> @change_count > 0 }

    bindings:
        'changes_visible': { selector: '.changes-notification', type: 'toggle' }
        'change_count': [
            { selector: '.changes-notification .title span',             type: 'text' }
            { selector: '.changes-notification .dropdown-toggle .badge', type: 'text' }
        ]

    subviews:
        changesDropDown:
            hook: 'changes-display'
            view: 'Lanes.Views.ModelUpdate'
            collection: 'changes'

    onChange: (model,change)->
        @changes.add(change)
        @change_count += 1

    bindModel: (model)->
        Lanes.Views.Base.prototype.bindModel.call(this, model)
        @changes.reset([])
        @change_count = 0

    onChangesShow: (ev)->
        this.changes.invoke('updateTimeAgo')
        this.$('.changes-notification .scroller').animate({ scrollTop: 0 })

}

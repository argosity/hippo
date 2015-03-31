Lanes.Screens.Mixins.Editing = {

    included: (klass)->
        klass::domEvents ||= {}
        _.extend(klass::domEvents,{
            'click .btn.save':  'saveRecord'
            'click .btn.reset': 'resetRecord'
            'display-record':   'onRecordTrigger'
        })

        klass::subviews ||= {}
        _.extend(klass::subviews,{
            finder: {
                component: 'RecordFinder'
                options: 'finderOptions'
                model: 'model'
            }
        })

    onRecordTrigger: (ev, model)->
        this.model = model

    resetRecord: ->
        options = _.result(this,'finderOptions')
        if options?.modelClass?
            this.model = new options.modelClass

    saveRecord: ->
        finder_options = _.result(this,'finderOptions')
        this.persistChanges?()
        options={}
        if finder_options?.withAssociations
            options.include = finder_options?.withAssociations
        Lanes.Views.SaveNotify(this,options)

    initialize: ->
        this.resetRecord()
}

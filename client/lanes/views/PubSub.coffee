# Responsible for adding and removing a view's model(s) from Models.PubSub
class Lanes.Views.PubSub extends Lanes.Views.ModelObserver

    modelEvents:
        'remote-update': 'onChange'

    hideUpdate: (field)->
        Lanes.dom.removeClass(field,"updated")

    showUpdate: (field)->
        Lanes.dom.addClass(field,"updated")
        _.delay(@hideUpdate, 3000, field )

    onChange: (model,change)->
        return unless change.record == this.getModel()
        for field in change.fields
            this.showUpdate(field) if field = @view.query("[name=#{field}]")

    bindModel: (model)->
        Lanes.Models.PubSub.add(model)
        super

    unBindModel: (model)->
        Lanes.Models.PubSub.remove(model)
        super

    teardown: ->
        super
        Lanes.Models.PubSub.remove(model) if model = this.getModel()

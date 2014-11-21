# Responsible for adding and removing a view's model(s) from Data.PubSub
class Lanes.View.PubSub extends Lanes.View.ModelObserver

    model_events:
        'remote-update': 'onChange'

    hideUpdate: (field)->
        _.dom.removeClass(field,"updated")

    showUpdate: (field)->
        _.dom.addClass(field,"updated")
        _.delay(@hideUpdate, 3000, field )

    onChange: (model,change)->
        return unless change.record == this.getModel()
        for field in change.fields
            this.showUpdate(field) if field = @view.query("[name=#{field}]")

    bindModel: (model)->
        Lanes.Data.PubSub.add(model)
        super

    unBindModel: (model)->
        Lanes.Data.PubSub.remove(model)
        super

    teardown: ->
        super
        Lanes.Data.PubSub.remove(model) if model = this.getModel()

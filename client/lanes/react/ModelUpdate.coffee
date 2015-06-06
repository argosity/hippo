class Lanes.Views.ModelUpdate extends Lanes.Views.Base


    templateData: ->
        { change: @model }

    bindings:
        'model.name': { selector: 'a', type: 'text' }
        'model.icon': { selector: 'i', type: 'class' }
        'model.time_ago': '.ago'

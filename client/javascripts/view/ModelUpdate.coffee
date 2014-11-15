class Lanes.View.ModelUpdate extends Lanes.View.Base

    templateName: 'view/model-update'

    bindings:
        'model.name':{ selector: 'a', type: 'text' }
        'model.icon': { selector: 'i', type: 'class' }
        'model.time_ago': '.ago'

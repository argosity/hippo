class Lanes.Test.DummyView extends Lanes.Views.Base
    formBindings:true
    template: "<p>hi</p"
    events: { "click #mylink": 'onClick' }
    onClick: Lanes.emptyFn

class Lanes.Test.DummyModel extends Lanes.Models.Base
    api_path: -> "test"
    props:
        id: 'number',
        name: ['string', true],
        html: 'string',
        url: 'string',
        something: 'string',
        fireDanger: 'string'

    session:
        active: 'boolean'

    derived:
        classes:
            deps: ['something', 'fireDanger', 'active'],
            fn: -> this.something + this.active;

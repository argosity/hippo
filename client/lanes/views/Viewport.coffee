ALL_INSTANCES = []

class Lanes.Views.Viewport extends Lanes.Models.State

    session:
        width:      'number'
        height:     'number'
        el:         'element'
        selector:   'string'
        root:       'element'

    constructor: ->
        super
        ALL_INSTANCES.push(this)
        this.on('change:root', =>
            @width = @root.width()
            @root.data()['ui']=@
        )

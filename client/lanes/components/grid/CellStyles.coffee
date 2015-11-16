class Lanes.Components.Grid.CellStyles

    constructor: (fields) ->
        @styles = []
        @classes = []
        @visibleIndexes = []
        @props = []

        for f, i in fields.models
            continue unless f.visible

            @styles[i]  = {flex: f.flex}
            if f.fixedWidth
                @styles[i].flexBasis = f.fixedWidth
                @styles[i].flexGrow  = 0

            @classes[i] = _.classnames( 'c', f.textAlign )
            @visibleIndexes.push(i)

            @props[i] = { className: @classes[i], style: @styles[i] }

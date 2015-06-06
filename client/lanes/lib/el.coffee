_.mixin(
    el: (name, attrs) ->
        unless _.isObject(attrs)
            attrs = {}
        unless _.isString(attrs['class'])
            attrs['class'] = ''
        unless  _.isString(attrs.id)
            attrs.id = ''
        class_pattern = /\.([\w\d-]+)/g
        id_pattern = /\#([\w-\d]+)/g
        (name.match(class_pattern) or []).forEach (clss) ->
            attrs['class'] += ' ' + clss
            return
        (name.match(id_pattern) or []).forEach (id) ->
            attrs.id += ' ' + id
            return
        name = name.replace(class_pattern, '').replace(id_pattern, '').trim()
        node = _.dom document.createElement(name)
        for name, value of attrs
            node.setAttribute(name, value)

        node.el
)

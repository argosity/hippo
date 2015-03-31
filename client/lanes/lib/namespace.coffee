# idea & basic implemntation from https://github.com/jashkenas/coffee-script/wiki/FAQ

Lanes.lib ||= {}

Lanes.namespace = (target, name, block) ->
    [target, name, block] = [(if typeof exports isnt 'undefined' then exports else Lanes), arguments...] if arguments.length < 3
    top    = target
    target = target[item] or= {} for item in name.split '.'
    block( target, top ) if typeof block == 'function'

for ns in ['Components', 'Models.Mixins', 'Views.Mixins', 'Screens.Mixins', 'Vendor', 'Templates', 'Extensions','lib']
    Lanes.namespace(ns)

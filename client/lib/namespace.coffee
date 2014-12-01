# idea & basic implemntation from https://github.com/jashkenas/coffee-script/wiki/FAQ

Lanes.lib ||= {}

Lanes.namespace = (target, name, block) ->
    [target, name, block] = [(if typeof exports isnt 'undefined' then exports else Lanes), arguments...] if arguments.length < 3
    top    = target
    target = target[item] or= {} for item in name.split '.'
    block( target, top ) if typeof block == 'function'

for ns in ['Components', 'Data.Mixins', 'Views.Mixins', 'Screens', 'Vendor', 'Templates', 'Extensions']
    Lanes.namespace(ns)

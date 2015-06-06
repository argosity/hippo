Lanes.lib.objToParam = (a) ->
    add = (s, k, v) ->
        v = if _.isFunction(v)
            v()
        else if v == null or v == undefined
            ''
        else
            v
        s[s.length] = k + '=' + encodeURIComponent(v)
        return

    buildParams = (prefix, obj, s) ->
        i = undefined
        len = undefined
        key = undefined
        if _.isArray(obj)
            i = 0
            len = obj.length
            while i < len
                val = (if _.isObject(obj[i]) then i else '')
                buildParams "#{prefix}[#{val}]", obj[i], s
                i++
        else if obj and _.isObject(obj)
            for key, value of obj
                if obj.hasOwnProperty(key)
                    if prefix
                        buildParams "#{prefix}[#{key}]", value, s, add
                    else
                        buildParams key, value, s, add
        else if prefix
            add s, prefix, obj
        else
            for key, value of obj
                add(s, key, value)
        s

    buildParams('', a, []).join('&').replace /%20/g, '+'

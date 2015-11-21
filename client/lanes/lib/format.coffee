Lanes.u.format ||= {}

Lanes.u.format.shartDateTime = (d) ->
    _.moment(d).format('lll')

Lanes.u.format.currency = (v) ->
    v ||= '0'
    _.sprintf('%0.2f', parseFloat(v))

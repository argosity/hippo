Lanes.u.format ||= {}

Lanes.u.format.shortDate = (d) ->
    _.moment(d).format('L')

Lanes.u.format.shortDateTime = (d) ->
    _.moment(d).format('lll')

Lanes.u.format.dateTime = (d) ->
    _.moment(d).format('YYYY-MM-DD hh:mm')

Lanes.u.format.currency = (v) ->
    v ||= '0'
    _.sprintf('%0.2f', parseFloat(v)).replace(/\B(?=(\d{3})+\b)/g, ",")

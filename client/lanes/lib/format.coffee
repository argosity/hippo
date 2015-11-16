Lanes.u.format ||= {}

Lanes.u.format.shartDateTime = (d) ->
    _.moment(d).format('lll')

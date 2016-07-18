if Element && !Element.prototype.matches
    proto = Element.prototype
    proto.matches = proto.matchesSelector ||
        proto.mozMatchesSelector || proto.msMatchesSelector ||
        proto.oMatchesSelector || proto.webkitMatchesSelector

unless _.isFunction(Object.assign)
    Object.assign = _.extend

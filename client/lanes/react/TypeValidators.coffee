Lanes.PropTypes ||= {}

checkerFor = (name, checker, isRequired) ->
    Lanes.PropTypes[name] = checker
    Lanes.PropTypes[name].isRequired = isRequired || (props, propName, componentName) ->
        return new Error("#{propName} must be given") unless props[propName]

checkerFor 'Model', (props, propName, componentName) ->
    val = props[propName]
    if val and (!_.isObject(val) or !val.isModel)
        return new Error("#{propName} is not a Lanes Model")

checkerFor 'State', (props, propName, componentName) ->
    val = props[propName]
    if val and (!_.isObject(val) or !val.isState)
        return new Error("#{propName} is not a state object")

checkerFor 'Collection', (props, propName, componentName) ->
    val = props[propName]
    if val and (!_.isObject(val) or !val.isCollection)
        return new Error("#{propName} is not a Lanes Collection")

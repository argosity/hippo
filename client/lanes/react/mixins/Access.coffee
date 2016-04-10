calculateAccess = (comp, props) ->

    model = _.result(comp, 'modelForAccess') ||
        comp.commands?.getModel()?.modelForAccess() ||
        comp.model?.modelForAccess()

    accessRight = if props.readonly or comp.context?.readonly
        'r'
    else if props.writable or comp.context?.writable or Lanes.current_user.canWrite(model, props.name)
        'w'
    else if props.readable or Lanes.current_user.canRead(model, props.name)
        'r'
    comp.setState({accessRight}) if accessRight

Lanes.React.Mixins.Access = {

    componentDidMount: ->
        calculateAccess(this, @props)

    componentWillReceiveProps: (newProps) ->
        calculateAccess(this, newProps)

    hasReadAccess: ->
        !!@state.accessRight

    hasWriteAccess: ->
        _.includes(['w', 'd'], @state.accessRight)


}

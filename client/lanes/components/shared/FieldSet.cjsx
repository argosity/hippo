class Lanes.Components.FieldSet extends Lanes.React.Component

    propTypes:
        title: React.PropTypes.string.isRequired
        expanded: React.PropTypes.bool
        containerClassName: React.PropTypes.string

    getDefaultProps: ->
        expanded: true

    getInitialState: ->
        expanded: @props.expanded

    componentWillReceiveProps: (nextProps) ->
        @setState(expanded: nextProps.expanded) if nextProps.expanded?

    toggleExpanded: ->
        @setState(expanded: not @state.expanded)

    render: ->
        colProps = _.omit(@props, 'name', 'expanded', 'bodyClassName')
        bodyClassName = _.classnames("container", @props.containerClassName)
        <BS.Col {...colProps}>
            <fieldset className={
                _.classnames("collapsible", @props.className, @state.icon
                    {expanded: @state.expanded, collapsed: !@state.expanded})
            }>
                <legend onClick={@toggleExpanded}>
                    {@props.title}
                </legend>
                <BS.Collapse in={@state.expanded}>
                    <div ref="body" className={bodyClassName} >
                        {@props.children}
                    </div>
                </BS.Collapse>
            </fieldset>
        </BS.Col>

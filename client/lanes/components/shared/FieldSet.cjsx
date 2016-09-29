class Lanes.Components.FieldSet extends Lanes.React.Component

    getDefaultProps: ->
        expanded: true

    propTypes:
        title: React.PropTypes.string.isRequired
        expanded: React.PropTypes.bool

    getInitialState: ->
        expanded: @props.expanded

    componentWillReceiveProps: (nextProps) ->
        @setState(expanded: nextProps.expanded) if nextProps.expanded?

    toggleExpanded: ->
        @setState(expanded: not @state.expanded)

    render: ->
        colProps = _.omit(@props, 'name', 'expanded')
        <BS.Col {...colProps}>
            <fieldset className={
                _.classnames("collapsible", @props.className, @state.icon
                    {expanded: @state.expanded, collapsed: !@state.expanded})
            }>
                <legend onClick={@toggleExpanded}>
                    {@props.title}
                </legend>
                <BS.Collapse in={@state.expanded}>
                    <div ref="body" className="fieldset-fields">
                        {@props.children}
                    </div>
                </BS.Collapse>
            </fieldset>
        </BS.Col>

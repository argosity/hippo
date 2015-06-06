class Lanes.Components.FieldSet extends Lanes.React.Component

    getDefaultProps: ->
        speed: 0.4

    propTypes:
        title: React.PropTypes.string.isRequired
        speed: React.PropTypes.number
        collapsed: React.PropTypes.bool

    getInitialState: ->
        state = {
            expanded: !@props.collapsed,
            icon: if @props.collapsed then 'plus' else 'minus'
        }
        state.height = 30 if @props.collapsed
        state

    getClientHeight: ->
        _.max(
            _.pluck(@refs.body.getDOMNode().children, 'clientHeight')
        ) + 45


    toggleExpanded: ->
        if @state.expanded
            if ! @state.hasExpanded
                @setState( hasExpanded: true, height: @getClientHeight() )
                _.defer @toggleExpanded
                return
            @setState expanded: false, height: 30
        else
            @setState expanded: true, height: @getClientHeight()

        _.delay( =>
            if @isMounted()
                @setState(icon: if @state.expanded then 'minus' else 'plus')
        , @props.speed * 1000)

    render: ->
        colProps = _.omit(@props, 'name')
        <BS.Col {...colProps}>
            <fieldset className={
                _.classnames("collapsible", @props.className, @state.icon
                {expanded: @state.expanded, collapsed: !@state.expanded})
            }
            style={
                maxHeight: @state.height
                transition: "max-height #{@props.speed}s ease-in-out";
            }>
                <legend onClick={@toggleExpanded}>
                    {@props.title}
                </legend>
                <div ref="body" className="fieldset-fields">
                    {@props.children}
                </div>
            </fieldset>
        </BS.Col>

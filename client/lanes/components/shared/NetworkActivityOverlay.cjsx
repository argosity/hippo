class Lanes.Components.NetworkActivityOverlay extends Lanes.React.Component

    propTypes:
        message: React.PropTypes.string
        timeout: React.PropTypes.number
        errorTimeout: React.PropTypes.number
        hasError: React.PropTypes.oneOfType([
            React.PropTypes.string, React.PropTypes.bool
        ])
        isRequesting: React.PropTypes.oneOfType([
            React.PropTypes.string, React.PropTypes.bool
        ])

    getDefaultProps: ->
        timeout: 30000, errorTimeout: 3000

    installRemoval: (props) ->
        if props.hasError or props.isRequesting
            clearTimeout(@state.removeHandler) if @state.removeHandler
        @setState(removeHandler: _.delay(@removeMessage,
            if props.hasError then @props.errorTimeout else @timeout
        ))

    componentWillMount: ->
        @installRemoval(@props)
        @setState(@props)

    removeMessage: ->
        return unless @isMounted()
        @setState(isRequesting: false, hasError: false)

    componentWillReceiveProps: (nextProps) ->
        @installRemoval(nextProps)
        @setState(nextProps)

    render: ->
        return null unless @state.isRequesting or @state.hasError

        if @props.hasError and not @state.hasError
            _.delay
        message = @props.message or (
            if @props.hasError
                if _.isString(@props.hasError) then @props.hasError else "Error"
            else if _.contains(['create', 'update', 'patch'], @props.isRequesting)
                'Saving…'
            else
                'Loading…'
        )
        icon = if @props.hasError then 'exclamation-circle' else 'spinner'
        <div className="overlay">
            <div className="mask" />
            <div className="message">
                <LC.Icon type={icon} animated={not @props.hasError} />
                {message}
            </div>
        </div>

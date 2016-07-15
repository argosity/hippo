class Lanes.Components.NetworkActivityOverlay extends Lanes.React.Component

    propTypes:
        model:   Lanes.PropTypes.Model
        message: React.PropTypes.string
        timeout: React.PropTypes.number
        visible: React.PropTypes.bool
        errorTimeout: React.PropTypes.number

    getDefaultProps: ->
        timeout: 30000, errorTimeout: 2000

    removeMessage: ->
        return unless @isMounted()
        @setState(isRequesting: false, hasError: false)

    clearTimeout: ->
        clearTimeout(@state.removeHandler) if @state.removeHandler

    installRemoval: (state) ->
        @clearTimeout()
        @setState(removeHandler: _.delay(@removeMessage,
            if state.hasError then @props.errorTimeout else @props.timeout
        ))

    listenNetworkEvents: true

    setModelState: (state) ->
        if state.hasError or state.isRequesting
            @installRemoval(state)
        else if not @state.hasError
            @removeMessage()
        @setState(state)

    render: ->
        return null unless @props.visible or @state.isRequesting or @state.hasError
        message = @props.message or (
            if @state.hasError
                errorMsg = @model.errorMessage
                if errorMsg and _.isString(errorMsg) then errorMsg else "Error"
            else if @state.isRequesting is 'GET'
                'Loading…'
            else if _.includes(['PATCH', 'POST', 'PUT'], @state.isRequesting)
                'Saving…'
            else if @state.isRequesting is 'DELETE'
                'Deleting…'
            else
                'Pending…'
        )
        icon = if @state.hasError then 'exclamation-circle' else 'spinner'
        classes = _.classnames 'overlay', {rounded: @props.roundedCorners}
        <div className={classes}>
            <div className="mask" />
            <div className="message">
                <LC.Icon type={icon} animated={not @state.hasError} />
                {message}
            </div>
        </div>

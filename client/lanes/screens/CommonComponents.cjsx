class Lanes.Screens.CommonComponents extends Lanes.React.Component

    propTypes:
        commands:        React.PropTypes.object.isRequired
        activity:        React.PropTypes.object.isRequired
        model:           Lanes.PropTypes.Model.isRequired
        toolbar:         React.PropTypes.bool
        errors:          React.PropTypes.bool
        networkActivity: React.PropTypes.bool

    render: ->
        <div>
            {<LC.NetworkActivityOverlay {...@props.activity} /> unless @networkActivity is false}
            {<LC.Toolbar {...@props} />                unless @toolbar         is false}
            {<LC.ErrorDisplay {...@props} />           unless @errors          is false}
        </div>

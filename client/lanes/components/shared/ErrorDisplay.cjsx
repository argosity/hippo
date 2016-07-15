class Lanes.Components.ErrorDisplay extends Lanes.React.Component

    propTypes:
        model:  Lanes.PropTypes.State.isRequired

    bindEvents: ->
        model: "change:error"

    clearErrors: ->
        @model.errors = null

    render: ->
        return null unless @model.errors
        <div className="alert alert-warning alert-dismissible" role="alert">
            <button onClick={@clearErrors} type="button" className="close"
                data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </button>
            <i className="icon icon-exclamation-circle" />
            { @model.errorMessage }
        </div>

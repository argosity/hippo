class Lanes.Components.JobStatus extends Lanes.React.Component

    propTypes:
        job: Lanes.PropTypes.State
        onlyExecuting: React.PropTypes.bool
        message: React.PropTypes.string

    pubsub: true
    listenNetworkEvents: true
    dataObjects: { job: 'props' }
    statusMessage: -> ''
    progressBar: ->
        return null unless @job.progress
        <BS.ProgressBar now={@job.progress * 100} />

    render: ->
        console.log 'jp rend'
        window.jbs = @job
        return null if @props.onlyExecuting and not @job.isExecuting
        <div className="job-executing">
            <h3 className="message">{@props.message}</h3>
            <LC.Throbber />
            <div className="status">{@statusMessage()}</div>
            {@progressBar()}
            {@props.children}
        </div>

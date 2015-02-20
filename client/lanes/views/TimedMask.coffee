class Lanes.Views.TimedMask
    stages:
        pending:
            msg: "Please Wait …"
            icon: "loading-spinner"
            color: 'darkGrey';
        success:
            msg: "Success!"
            icon: "icon-thumbs-up"
            color: 'blue'
        failure:
            msg: "Failed"
            icon: "icon-warning"
            color: 'darkRed'
        timeout:
            msg: "Timed Out …"
            icon: "icon-busy"
            color: 'firebrick'

    failsafeTimeout: 25000
    defaultTimeout:   1500

    constructor: ( @element, options={} )->
        _.bindAll(this,'destroy')
        if _.isString( options )
            @stages.pending.msg = options
        else
            _.defaults(this, options)
        @element.overlay( @stages.pending )

        @timeout = _.delay( =>
            @_failSafeDestruct()
        ,@failsafeTimeout)
        this

    prefixActions: (msg)->
        stage.msg ="#{msg} #{stage.msg}" for stage in @stages

    display: (success, msg)->
        if success then this.displaySuccess(msg) else this.displayFailure(msg)

    displaySuccess: ( msg = @stages.success.msg, opts={}  )->
        this._display( msg, opts, 'success' )

    displayFailure: ( msg = @stages.failure.msg, opts={} )->
        this._display( msg, opts, 'failure' )

    _display:(msg, opts, stage)->
        this._sceduleDestruct( opts.timeOut )
        opts = _.extend( _.clone(@stages[stage]), opts)
        _.extend(opts, {msg:msg}) if msg
        @element.overlay( opts )

    _failSafeDestruct: ->
        this._display( null, {timeOut: 5000}, 'timeout' )

    _sceduleDestruct: (time=@defaultTimeout)->
        clearTimeout(@timeout)
        @timeout = _.delay( =>
            @destroy()
        ,time)

    destroy: ->
        @element.overlay(false)
        clearTimeout(@timeout)

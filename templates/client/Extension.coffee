# This is the client-side version of <%= namespace %>::Extension
class <%= namespace %>.Extension extends Lanes.Extensions.Base

    # must match the identier in
    identifier: "<%= identifier %>"

    # This method is called when the extension is registered
    # Not all of Lanes will be available yet
    onRegistered: ->

    # Data that is provided by <%= namespace %>::Extension#client_bootstrap_data
    # in lib/<%= identifier %>/extension.rb is passed to this method
    setBootstrapData: (data)->

    # All of lanes is loaded and it is in the process of booting
    onAvailable: ->

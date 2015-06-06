# This is the client-side version of AppyApp::Extension
class AppyApp.Extension extends Lanes.Extensions.Base

    # must match the server-side identier in config/screens.rb and lib/appy-app/extension.rb
    identifier: "appy-app"

    # This method is called when the extension is registered
    # Not all of Lanes will be available yet
    onRegistered: Lanes.emptyFn

    # This method is called after Lanes is completly loaded
    # and all extensions are registered
    onInitialized: Lanes.emptyFn

    # Data that is provided by AppyApp::Extension#client_bootstrap_data
    # in lib/appy-app/extension.rb is passed to this method
    setBootstrapData: Lanes.emptyFn

    # All extenensions have been given their data and Lanes has completed startup
    onAvailable: Lanes.emptyFn

    # Routes that should be established go here
    getRoutes: -> null

    # The root component that should be shown for this extension.
    # Will not be called if a different extension has included this one and it is the
    # "controlling" extension
    rootComponent: (viewport) -> null

import {
    BaseExtension, identifiedBy, identifier,
} from 'hippo/extensions/base';

@identifiedBy('extensions/appy-app')
export default class Extension extends BaseExtension {

    // must match the server-side identier in config/screens.rb
    // and lib/appy-app/extension.rb
    @identifier id = 'appy-app';

    // This method is called when the extension is registered
    // Not all of Hippo will be available yet
    onRegistered() { }

    // This method is called after Hippo is completly loaded
    // and all extensions are registered
    onInitialized() { }

    // All extenensions have been given their data and Hippo has completed startup
    onAvailable() { }

    // Data that is provided by AppyApp::Extension#client_bootstrap_data
    // in lib/appy-app/extension.rb is passed to this method
    // the Base class will simply store the provided data as @data
    setBootstrapData() { return super.setBootstrapData(...arguments); }

    // The root view that will be rendered when a screen is not being shown
    // Return a different component here to customize
    rootView() { return super.rootView(); }

    // A React component that should be rendered as part of the settings screen
    get systemSettingsComponent() {
        return null;
    }
}

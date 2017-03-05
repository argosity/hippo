// This is the client-side version of AppyApp::Extension
import { BaseModel, identifiedBy, identifier } from './models/base';

@identifiedBy('extensions/appy-app');
class AppyAppExtension extends BaseModel {

    // must match the server-side identier in config/screens.rb
    // and lib/appy-app/extension.rb
    @identifier id = 'appy-app';

    // This method is called when the extension is registered
    // Not all of Lanes will be available yet
    onRegistered() { }

    // This method is called after Lanes is completly loaded
    // and all extensions are registered
    onInitialized() { }

    // All extenensions have been given their data and Lanes has completed startup
    onAvailable() { }


    // Data that is provided by AppyApp::Extension#client_bootstrap_data
    // in lib/appy-app/extension.rb is passed to this method
    // the Base class will simply store the provided data as @data
    setBootstrapData() { return super.setBootstrapData(...arguments); }

    // Routes that should be established go here
    getRoutes() { return null; }

    // The root component that should be shown for this extension.
    // Will not be called if a different extension has included this one and it is the
    // "controlling" extension
    rootComponent(viewport) { return null; }
}

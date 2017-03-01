// This is the client-side version of <%= namespace %>::Extension
import { BaseModel, modelDecorator, identifier } from './models/base';

@modelDecorator('extensions/<%= identifier %>');
class <%= namespace %>Extension extends BaseModel {

    // must match the server-side identier in config/screens.rb
    // and lib/<%= identifier %>/extension.rb
    @identifier id = '<%= identifier %>';

    // This method is called when the extension is registered
    // Not all of Lanes will be available yet
    onRegistered() { }

    // This method is called after Lanes is completly loaded
    // and all extensions are registered
    onInitialized() { }

    // All extenensions have been given their data and Lanes has completed startup
    onAvailable() { }


    // Data that is provided by <%= namespace %>::Extension#client_bootstrap_data
    // in lib/<%= identifier %>/extension.rb is passed to this method
    // the Base class will simply store the provided data as @data
    setBootstrapData() { return super.setBootstrapData(...arguments); }

    // Routes that should be established go here
    getRoutes() { return null; }

    // The root component that should be shown for this extension.
    // Will not be called if a different extension has included this one and it is the
    // "controlling" extension
    rootComponent(viewport) { return null; }
}

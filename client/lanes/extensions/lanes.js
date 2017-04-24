// This is the client-side version of Sh::Extension
import {
    BaseExtension, identifiedBy, identifier,
} from './base';

@identifiedBy('extensions/lanes')
export default class LanesExtension extends BaseExtension {

    @identifier id = 'lanes';

}

// This is the client-side version of Sh::Extension
import {
    BaseExtension, identifiedBy, identifier,
} from './base';

import Extensions from './index';

@identifiedBy('extensions/hippo')
export default class HippoExtension extends BaseExtension {
    @identifier id = 'hippo';
}


Extensions.register(HippoExtension);

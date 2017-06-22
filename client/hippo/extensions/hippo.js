// This is the client-side version of Sh::Extension
import {
    BaseExtension, identifiedBy, identifier,
} from './base';

@identifiedBy('extensions/hippo')
export default class HippoExtension extends BaseExtension {
    @identifier id = 'hippo';
}

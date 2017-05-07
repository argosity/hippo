import { observable, computed } from 'mobx';
import { titleize, humanize } from '../lib/util';
import Extensions from './index';

export { identifiedBy, identifier } from '../models/base';


export class BaseExtension {

    @observable data;

    static register() {
        Extensions.register(this);
    }

    @computed get title() {
        return titleize(humanize(this.identifier));
    }

    setBootstrapData(data) {
        this.data = data;
    }
}

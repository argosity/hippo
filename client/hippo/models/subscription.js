import Big from 'big.js';
import { map } from 'lodash';
import Config from '../config';
import {
    BaseModel, identifiedBy, identifier, field, session, computed,
} from './base';

@identifiedBy('hippo/subscription')
export default class Subscription extends BaseModel {

    @computed static get all() {
        return map(Config.subscription_plans, plan => new Subscription(plan));
    }

    @identifier id;

    @field name;

    @field description;

    @field price;

    @field nonce;

    @session authorization;

    @computed get formattedPrice() {
        return Big(this.price).round(2).toFixed(2);
    }

    @computed get costDescription() {
        return `${this.formattedPrice} per month`;
    }

    @computed get nameAndCost() {
        return `${this.name} at ${this.costDescription}`;
    }

}

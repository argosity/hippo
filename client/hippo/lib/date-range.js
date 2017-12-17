import moment from 'moment-timezone';
import { observable, computed, isObservableArray, intercept } from 'mobx';
import { includes, isString, isEmpty, map, isArray, first, last } from 'lodash';
import {
    identifiedBy,
} from 'mobx-decorated-models';

function coerceToMoment(change) {
    if (!includes(['start', 'end'], change.name)) { return change; }
    if (!change.newValue && !moment.isMoment(change.newValue)) {
        change.newValue = moment(change.newValue);
    }
    return change;
}


@identifiedBy('date-range')
export default class DateRange {

    @observable start;
    @observable end;

    constructor(range) {
        intercept(this, coerceToMoment);
        if (isString(range) && !isEmpty(range)) {
            [this.start, this.end] = map(range.split('...'), d => new Date(d));
        } else if (isArray(range) || isObservableArray(range)) {
            this.start = first(range);
            this.end = last(range);
        } else if (range) {
            this.start = range.start;
            this.end = range.end;
        }
    }

    toJSON() {
        if (this.start && this.end && this.start.isValid() && this.end.isValid()) {
            // this strange format is what PG uses and is therefore what active record expects
            return `[${this.start.toISOString()},${this.end.toISOString()})`;
        }
        return '';
    }

    static serialize(range) {
        return (range ? range.toJSON() : '');
    }

    @computed get isCurrent() {
        return moment(this.end).isAfter() && moment(this.start).isBefore();
    }

    @computed get asArray() {
        return [this.start, this.end];
    }

}

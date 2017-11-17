import moment from 'moment';
import { observable, computed, isObservableArray } from 'mobx';
import { isString, isEmpty, map, isNaN, isArray, first, last } from 'lodash';
import {
    identifiedBy,
} from 'mobx-decorated-models';

@identifiedBy('date-range')
export default class DateRange {

    @observable start;
    @observable end;

    constructor(range) {
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
        if (this.start && this.end && !isNaN(this.start.getTime()) && !isNaN(this.end.getTime())) {
            // this strange format is what PG user and is therefore what active record expects
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

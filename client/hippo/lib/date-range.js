import { isString, isEmpty, map } from 'lodash';
import {
    identifiedBy,
} from 'mobx-decorated-models';

@identifiedBy('date-range')
export default class DateRange {
    constructor(range) {
        if (isString(range) && !isEmpty(range)) {
            [this.start, this.end] = map(range.split('..'), d => new Date(d));
        } else if (range) {
            this.start = range.start;
            this.end = range.end;
        }
    }

    toJSON() {
        if (this.start && this.end) {
            // this strange format is what PG user and is therefore what active record expects
            return `[${this.start.toISOString()},${this.end.toISOString()})`;
        }
        return '';
    }

    static serialize(range) {
        return (range ? range.toJSON() : '');
    }
}

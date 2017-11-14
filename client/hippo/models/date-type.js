import { registerCustomType } from 'mobx-decorated-models';
import moment from 'moment-timezone';

registerCustomType('fdate', {

    serialize(date) {
        return date.toISOString();
    },

    deserialize(dateLikeThing) {
        return moment(dateLikeThing);
    },

});

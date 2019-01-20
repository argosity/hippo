import { identifier as mobxIdentifier, registerCustomType } from 'mobx-decorated-models';
import {
    isEmpty, isNumber, defaults,
} from 'lodash';
import moment from 'moment';

registerCustomType('number', {
    serialize(num) { return num; },
    deserialize(num) { return isNumber(num) ? num : Number(num); },
});

registerCustomType('date', {
    serialize(date) { return date; },
    deserialize(date) { return moment.isMoment(date) ? date : moment(date); },
});

function decoratorWrapper(decorator, defaultOptions = {}) {
    return (targetOrOptions, ...args) => {
        const options = isEmpty(args)
            ? defaults(targetOrOptions, defaultOptions) : defaultOptions;

        const wrap = (target, property, descriptor) => {
            const decorationFn = decorator(options);
            const description = decorationFn(target, property, descriptor);
            return description;
        };

        if (isEmpty(args)) { // we were given options
            return (target, property, descriptor) => wrap(target, property, descriptor);
        }
        return wrap(targetOrOptions, args[0], args[1]);
    };
}

const identifier = decoratorWrapper(mobxIdentifier, { type: 'number' });

export { identifier }; // eslint-disable-line import/prefer-default-export

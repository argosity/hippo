import {
    negate, isNil, isString, isObject, mapValues, extend, forIn, isFunction, pick, isBoolean, get, keys,
    merge,
} from 'lodash';
import moment from 'moment';
import isEmail from 'validator/lib/isEmail';
import isURL from 'validator/lib/isURL';
import { isBlank } from '../lib/util';

export Form from './form/wrapper';
export Field from './form/fields';
export FieldDefinitions from './form/model';
export FormFieldPropType from './form/field-prop-type';

function buildTest(options, defaultOptions) {
    return merge({}, defaultOptions, options);
}

export function hasLength(length) {
    const options = isObject(length) ? length : { length };
    return buildTest(options, {
        message: `must be of length ${length}`,
        test(s) {
            return s && (s.length >= this.length);
        },
    });
}

const NUMBER = /^[+-]?(\d*\.)?\d+$/;
export function numberValue(options = {}) {
    return buildTest(options, { message: 'must be a number', test: v => NUMBER.test(v) });
}

export function stringValue(options) {
    return buildTest(options, { message: 'must be a string', isString });
}

const PHONE = /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/;
export function validPhone(options = {}) {
    return buildTest(options, { message: 'need 10 digit phone number', test: v => PHONE.test(v) });
}

export function validEmail(options) {
    return buildTest(options, { message: 'must be a valid email', test: email => isEmail(email || '') });
}

export function validURL(options = {}) {
    return buildTest(options, {
        message: 'must be a valid address',
        test(url) {
            return (options.allowBlank && !url) || isURL(url || '');
        },
    });
}

export function booleanValue(options = {}) {
    return buildTest(options, { message: 'must be true or false', test: isBoolean });
}

export function nonBlank(options = {}) {
    return buildTest(options, { message: 'is required', test: negate(isBlank) });
}

export function dateValue(options = {}) {
    return buildTest(options, { message: 'must be valid date', test: v => moment(v, options.format).isValid() });
}

export function field(options) {
    return buildTest(options, { test: () => true });
}

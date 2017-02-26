import { negate, isNil, mapValues, extend, get, isFunction } from 'lodash';
import isEmail from 'validator/lib/isEmail';
import Formous from 'formous';

import { isBlank } from './util';

function buildTest(defaultOptions, defaultMessage, test) {
    const { test: defaultTest, critical, message, name, ...otherOptions } = defaultOptions;
    return extend({
        tests: [{
            test: test || defaultTest,
            critical: isNil(critical) ? true : critical,
            failProps: {
                errorText: message || defaultMessage || 'is invalid',
            },
        }],
    }, otherOptions);
}

export function hasLength(len) {
    return options =>
        buildTest(options, `must be of length ${len}`, s => s.length >= len);
}

export function validEmail(options = {}) {
    return buildTest(options, 'must be a valid email', isEmail);
}

export function nonBlank(options = {}) {
    return buildTest(options, 'is required', negate(isBlank));
}

export function validation(options = {}) {
    return buildTest(options, 'is required', options.test);
}

export function buildValidations(options = {}) {
    return mapValues(options, (v, name) => (isFunction(v) ? v({ name }) : v));
}

export function WithValidatedFields(fields, component, extensions = {}) {
    const options = { fields: buildValidations(fields) };
    return extend(Formous(options)(component), extensions);
}

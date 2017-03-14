import {
    negate, isNil, isString, mapValues, extend, forIn, has, isFunction, pick,
} from 'lodash';
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

export function stringValue(options = {}) {
    return buildTest(options, 'must be a string', isString);
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

export function setFieldValue(field, value) {
    if (!field.events) { return; }
    field.cid = Math.random()
    field.events.onChange({ target: { value: isNil(value) ? '' : value } });
    field.value = value;
}

export function setFieldValues(fields, values) {
    forIn(fields, (field, name) => {
        setFieldValue(field, values[name]);
    });
}

export function addFormFieldValidations(component, ...staticProps) {
    const options = { fields: buildValidations(component.formFields) };
    return extend(Formous(options)(component), pick(component, staticProps));
}

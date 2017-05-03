import {
    negate, isNil, isString, mapValues, extend, forIn, isFunction, pick, isBoolean, get, keys,
} from 'lodash';
import moment from 'moment'
import isEmail from 'validator/lib/isEmail';
import Formous from 'formous';
import { when } from 'mobx';
import { isBlank } from './util';

function buildTest(defaultOptions, defaultMessage, test) {
    const { test: defaultTest, critical, message, name: _, ...otherOptions } = defaultOptions;
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

const NUMBER = /^[+-]?(\d*\.)?\d+$/;

export function numberValue(options = {}) {
    return buildTest(options, 'must be a number', v => NUMBER.test(v));
}

export function stringValue(options = {}) {
    return buildTest(options, 'must be a string', isString);
}

export function validEmail(options = {}) {
    return buildTest(options, 'must be a valid email', email => isEmail(email || ''));
}

export function booleanValue(options = {}) {
    return buildTest(options, 'must be true or false', isBoolean);
}

export function nonBlank(options = {}) {
    return buildTest(options, 'is required', negate(isBlank));
}

export function dateValue(options = {}) {
    return buildTest(options, 'must be valid date', v => moment(v, options.format).isValid());
}

export function validation(options = {}) {
    return buildTest(options, 'is required', options.test);
}

export function buildValidations(options = {}) {
    return mapValues(options, (v, name) => (isFunction(v) ? v({ name }) : v));
}

export function testWith(fn, msg='is invalid') {
    return buildTest({}, msg, fn);
}

const passEverything = () => true;

export function anyValue() {
    return buildTest({}, '', passEverything);
}

export function setFieldValue(field, value) {
    if (!field.events) { return; }

    field.events.onChange({ target: { value: isNil(value) ? '' : value } });
}

export function setFieldValues(props, values) {
    props.setFieldValues(pick(values, keys(props.fields)));
}

export function setFieldsFromModel(props, model) {
    if (get(model, 'syncInProgress.isFetch')) {
        when(
            () => !get(model, 'syncInProgress.isFetch'),
            () => setFieldValues(props, model),
        );
    } else {
        setFieldValues(props, model);
    }
}

export function persistFieldValues(props, model) {
    forIn(props.fields, (field, name) => (model[name] = field.value)); // eslint-disable-line
    return Promise.resolve(model);
}

export function addFormFieldValidations(component, ...staticProps) {
    const options = { fields: buildValidations(component.formFields) };
    return extend(Formous(options)(component), pick(component, staticProps));
}

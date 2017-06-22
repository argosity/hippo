import logger from 'loglevel';
import {
    trim, isDate, isNaN, isError, isElement, isFunction, isBoolean, isRegExp,
    isNumber, isObject, isEmpty, isNil, isString, each,
} from 'lodash';
import pluralize from 'pluralize';

function lcDash(char, match, index) {
    return (0 === index ? '' : '_') + char.toLowerCase();
}

export { logger };

export function emptyFn() {}

export function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}

export function dasherize(str) {
    return trim(str)
        .replace(/([A-Z])/g, lcDash)
        .replace(/[-_\s]+/g, '-')
        .toLowerCase();
}

export function titleize(words) {
    if ('string' !== typeof words) { return words; }
    return (words)
        .replace(/[\W_]/g, ' ')
        .replace(/\S+/g, word => (word.charAt(0).toUpperCase() + word.slice(1)),
        );
}

export function underscored(str) {
    return trim(str)
        .replace(/([a-z\d])([A-Z]+)/g, '$1_$2')
        .replace(/[-\s]+/g, '_')
        .toLowerCase();
}

export function humanize(str) {
    return capitalize(trim(underscored(str)
        .replace(/_id$/, '')
        .replace(/_/g, ' ')));
}

export function renameProperties(object, keyMap) {
    each(keyMap, (to, from) => {
        if (object[from]) {
            object[to] = object[from]; // eslint-disable-line no-param-reassign
            delete object[from]; // eslint-disable-line no-param-reassign
        }
    });
    return object;
}

export function toSentence(sentence, comma = ', ', nd = ' and ') {
    let words = isString(sentence) ? sentence.split(' ') : sentence;
    if (null == words) { words = []; }
    const last = words.pop();
    if (last) {
        return words.length ? [words.join(comma), last].join(nd) : last;
    }
    return '';
}

export function singular(str) {
    return pluralize.singular(str);
}

export function classify(str) {
    return str
        .replace(/\S+/g, word => (word.charAt(0).toUpperCase() + word.slice(1)))
        .replace(/-\S+/g, word => (word.charAt(1).toUpperCase() + word.slice(2)))
        .replace(/\/\S+/g, word => (`::${word.charAt(1).toUpperCase()}${word.slice(2)}`))
        .replace(/\s/g, '');
}

export function isBlank(value) {
    switch (true) {
    case isDate(value):
        return isNaN(value.getDate());
    case isError(value):
    case isNaN(value):
        return true;
    case isElement(value):
    case isFunction(value):
    case isBoolean(value):
    case isRegExp(value):
        return false;
    case isNumber(value):
        return !value;
    case isObject(value):
        return isEmpty(value);
    case isString(value):
        return isEmpty(trim(value));
    default:
        return isNil(value);
    }
}

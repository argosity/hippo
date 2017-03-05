import {
    isEmpty, isArray, isNumber, isObject, isString, isFunction,
    partial, defaults, merge, isNil,
} from 'lodash';
import invariant from 'invariant';
import { getDefaultModelSchema } from 'serializr';
import { action, computed, observable as mobxObservable, intercept } from 'mobx';

import {
    identifiedBy as mobxModelDecorator,
    field as mobxField,
    session as mobxSession,
    identifier as mobxIdentifier,
    belongsTo as mobxBelongsTo,
    hasMany as mobxHasMany,
    getModelSchema,
} from 'mobx-decorated-models';

//import  from 'mobx-decorated-models/lib/schema';

const VALIDATORS = {
    number: isNumber,
    string: isString,
    array:  isArray,
    object: isObject,
};

function addLazyInitializer(target, fn) {
    target.__mobxLazyInitializers.push(fn);
}

function validateChangeType(validator, propertyName, change) {
    if (isNil(change.newValue)) { return change };
    invariant(VALIDATORS[validator], `Unknown TypeCheck: ${validator} does not exist`);
    invariant(VALIDATORS[validator](change.newValue),
              `Bad Type: Attempted to set ${propertyName} to '${change.newValue}' which is not ${validator}`);
    return change;
}

function addTypeSafeInterceptor(target, property, type) {
    if (isEmpty(type)) { return; }
    addLazyInitializer(target, (partial(intercept, partial.placeholder, property,
                                        partial(validateChangeType, type, property))));
}

function decoratorWrapper(decorator, defaultOptions = {}) {
    return (targetOrOptions, ...args) => {
        const options = isEmpty(args) ?
              defaults(targetOrOptions, defaultOptions) : defaultOptions;

        const wrap = (target, property, descriptor) => {
            const decorationFn = decorator(options);
            const description = decorationFn(target, property, descriptor);
            addTypeSafeInterceptor(target, property, options.type);
            return description;
        };

        if (isEmpty(args)) { // we were given options
            return (target, property, descriptor) => wrap(target, property, descriptor);
        }
        return wrap(targetOrOptions, args[0], args[1]);
    };
}

const field = decoratorWrapper(mobxField);
const session = decoratorWrapper(mobxSession);
const identifier = decoratorWrapper(mobxIdentifier, { type: 'number' });


// const wrapAssociation = (assoc, onChange) => {
//     const interceptor = (property, model) => {
//         const serialize = getDefaultModelSchema(model).props[property];
//         intercept(model, property, partial(onChange, partial.placeholder, serialize));
//     };
//     return (targetOrOptions, ...args) => {
//         const decorated = assoc(targetOrOptions, ...args);
//         if (isObject(targetOrOptions)) {
//             return (target, property, descriptor) => {
//                 const invokedDecoration = decorated(target, property, descriptor);
//                 addLazyInitializer(target, partial(interceptor, property));
//                 return invokedDecoration;
//             };
//         }
//         addLazyInitializer(targetOrOptions, partial(interceptor, args[0]));
//         return decorated;
//     };
// };


export { field, session, identifier };


// export function observable(target, property, descriptor) {
//     getModelSchema(target.constructor).set(property, { name: property, type: 'observable', options: {} });
//     return mobxObservable(target, property, descriptor);
// }

// Object.keys(mobxObservable).forEach((prop) => {
//     observable[prop] = mobxObservable[prop];
// });

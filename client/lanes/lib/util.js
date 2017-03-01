import logger from 'loglevel';
import {
    trim, isDate, isNaN, isError, isElement, isFunction, isBoolean, isRegExp,
    isNumber, isObject, isEmpty, isNil, isString,
} from 'lodash';
import pluralize from 'pluralize';

// const distillTypes = (type, ns) => _.reduce( type.split( '.' ), ( ( memo, val ) => memo ? memo[ val ] : null),  ns );

function lcDash(char, match, index) {
    return (index === 0 ? '' : '_') + char.toLowerCase();
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
    if (typeof words !== 'string') { return words; }
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


export function toSentence(sentence, comma = ', ', nd = ' and ') {
    let words = isString(sentence) ? sentence.split(' ') : sentence;
    if (words == null) { words = []; }
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
        .replace(/\/\S+/g, word => ('::' + word.charAt(1).toUpperCase() + word.slice(2)))
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

    // fatal(...args) {
    //     this.warn(...args);
    //     throw new Error(...args);
    // },

    // warn(...msg) {
    //     if (!console) { return; }
    //     if (msg[0] instanceof Error) {
    //         console.warn(msg[0].stack);
    //     } else { console.warn(...msg); }
    //     return null;
    // },

    // utcToLocalDate(val) {
    //     return new Date(val.getTime() - (val.getTimezoneOffset() * 60000));
    // },

    // dateToUTC(val) {
    //     return new Date(
    //         val.getUTCFullYear(), val.getUTCMonth(),   val.getUTCDate(),
    //         val.getUTCHours(),    val.getUTCMinutes(), val.getUTCSeconds()
    //     );
    // },

    // cleanBsSizes(props) {
    //     return _.omit(props, this.getBsSizeProps() );
    // },

    // bsSizes(props) {
    //     return _.pick(props, this.getBsSizeProps());
    // },

    // getBsSizeProps() {
    //     return [ 'xs', 'sm', 'md', 'lg',
    //       'xsOffset', 'smOffset', 'mdOffset', 'lgOffset' ];
    // },

    // makeComparatorUsing(method) {
    //     return (a, b) => Lanes.u.comparator(a[method], b[method]);
    // },

    // comparator(a, b) {
    //     if (a < b) { return 1; } else if (a > b) { return -1; } else { return 0; }
    // },

    // objectForPath(path) {
    //     const parts = path.replace(/\.js$/, '').split('/');
    //     let last = null;
    //     return _.reduce( parts, (memo, val) => last = memo[val] || memo[ _.classify(val) ] || last
    //     , Lanes);
    // },

    // objectPath(FILE) {
    //     return FILE.path;
    // },

    // path(FILE) {
    //     return FILE.path.join("/");
    // },

    // dirname(FILE) {
    //     return FILE.path.slice(0, FILE.path.length - 1).join("/");
    // },

    // findObject(name, subPath, file) {
    //     if (file == null) { file = FILE; }
    //     if (_.isObject(name)) {
    //         return name;
    //     } else {
    //         return __guard__(file.namespace[subPath], x => x[name]) || __guard__(Lanes[subPath], x1 => x1[name]) || Lanes.u.getPath(name);
    //     }
    // },

    // findRelative(name, file) {
    //     const parts = _.map(file.path.slice(0, file.path.length - 1), comp => _.classify(comp));
    //     const obj = _.reduce( parts, ( ( memo, val ) => memo ? memo[ val ] : null), Lanes );
    //     return __guard__(obj, x => x[name]);
    // },

    // isModel(object) {
    //     return (_.isObject(object) && object.isProxy) || object instanceof Lanes.Models.BasicModel;
    // },

    // isCollection(object) {
    //     return object instanceof Lanes.Models.Collection ||
    //         object instanceof Lanes.Models.BasicCollection ||
    //         object instanceof Lanes.Models.SubCollection;
    // },

    // isState(object) {
    //     return (_.isObject(object) && object.isProxy) || object instanceof Lanes.Models.State;
    // },

    // // Can be called one of two ways:
    // // With ns being a string, which will attempt to deref it then deref name inside it
    // // or with ns being an object, which will dref name inside it
    // getPath( name, ns ) {
    //     if (ns == null) { ns = 'Lanes'; }
    //     if (!_.isString(name)) { return name; }
    //     if (_.isString(ns) && !ns.match("Lanes")) { ns = `Lanes.${ns}`; }
    //     let object = distillTypes(name, window);
    //     if (!object) {
    //         ns = _.isObject(ns) ? ns : distillTypes(ns, window);
    //         object = distillTypes(name, ns );
    //     }
    //     return object;
    // },

    // // Like underscore's results but allows passing
    // // arguments to the function if it's called
    // resultsFor( scope, method, ...args ) {
    //     if (_.isString(method)) {
    //         if (_.isFunction(scope[method])) {
    //             return scope[method].apply(scope, args);
    //         } else {
    //             return scope[method];
    //         }
    //     } else if (_.isFunction(method)) {
    //         return method.apply(scope, args);
    //     } else {
    //         return method;
    //     }
    // },

    // invokeOrReturn(func, scope) {
    //     if (scope == null) { scope = this; }
    //     if (_.isFunction(func)) {
    //         return func.apply(scope);
    //     } else {
    //         return func;
    //     }
    // },





// function __guard__(value, transform) {
//   return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
// }

// credit to https://github.com/jayphelps/core-decorators/blob/master/src/lazy-initialize.js
export default function lazyGetter(target, key, descriptor) {
    const { configurable, initializer, value } = descriptor;

    return {
        configurable,
        enumerable: false,

        get() {
            // This happens if someone accesses the
            // property directly on the prototype
            if (this === target) {
                return null;
            }

            const ret = initializer ? initializer.call(this) : value;

            Object.defineProperty(this, key, {
                configurable,
                enumerable: false,
                writable: false,
                value: ret,
            });

            return ret;
        },

    };
}

const babelOptions = {
    plugins: [
        'babel-plugin-dynamic-import-node',
        'babel-plugin-transform-decorators-legacy',
        'babel-plugin-transform-class-properties',
        'babel-plugin-transform-function-bind',
        'babel-plugin-transform-react-jsx',
        'babel-plugin-transform-runtime',
    ].map(require.resolve),
    presets: [
        require.resolve('babel-preset-es2015'),
        require.resolve('babel-preset-react'),
        require.resolve('babel-preset-stage-1'),
    ],
};

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const jestPreset = require('babel-preset-jest');
const babel = require('babel-core');

const createTransformer = (options) => {
    options = Object.assign({}, options, {
        plugins: (options && options.plugins) || [],
        presets: ((options && options.presets) || []).concat([jestPreset]),
        retainLines: true,
    });
    delete options.cacheDirectory;
    delete options.filename;

    return {
        canInstrument: false,
        getCacheKey(fileData) {
            return crypto.createHash('md5').update(fileData).digest('hex');
        },
        process(src, filename) {
            if (!babel.util.canCompile(filename)) {
                return src;
            }
            const theseOptions = Object.assign({ filename }, options);
            return babel.transform(src, theseOptions).code;
        },
    };
};

module.exports = createTransformer(babelOptions);

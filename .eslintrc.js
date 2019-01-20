module.exports = {
    extends: "argosity",
    parser: "babel-eslint",
    parserOptions: {
        ecmaFeatures: {
            legacyDecorators: true
        }
    },
    settings: {
        react: {
            version: "detect",
        },
    },
};

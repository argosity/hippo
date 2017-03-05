module.exports = {
    "extends": "airbnb",
    "parser": "babel-eslint",
    "installedESLint": true,
    "rules": {
        "indent": [2, 4],
        "camelcase": 0,
        "func-names": 0,
        "space-before-function-paren": ["error", "never"],
        "yoda": [2, "always"],
        "no-multi-spaces": [2, {
            "exceptions": {
                "Identifier": true,
                "ClassProperty": true,
                "ImportDeclaration": true,
                "VariableDeclarator": true,
                "AssignmentExpression": true,
            },
        }],
        "no-unused-vars": [2, {"varsIgnorePattern": "_+"}],
        "react/prefer-stateless-function": [2, {
            "ignorePureComponents": true
        }],
        "key-spacing": [2, {
            "singleLine": {
                "beforeColon": false,
                "afterColon":  true
            },
            "multiLine": {
                "beforeColon": false,
                "afterColon":  true,
                "mode": "minimum"
            }
        }],
        "react/jsx-indent": [2, 4],
        "react/jsx-indent-props": [2, 4],
        "import/no-unresolved": 0,
        "import/extensions": 0,
        "class-methods-use-this": 0,
        "import/no-extraneous-dependencies": [0, { devDependencies: true }]
    },
    "globals": {
        "fetch": false
    },
    "plugins": [
        "react",
        "jsx-a11y",
        "import",
    ],
};

{
    "verbose": true,
    "notify": false,
    "testRegex": ".*\\.spec\\.(js|jsx)$",
    "moduleFileExtensions": [ "coffee", "js", "cjsx", "jsx", "json" ],
    "setupTestFrameworkScriptFile": "<rootDir>/lib/js/jest/setup.js",
    "modulePaths": [
        "<rootDir>/client",
        "<rootDir>/lib/js/jest/stubs"
    ],
    "moduleNameMapper": {
        "\\.(css|less|scss)$": "<rootDir>/lib/js/jest/styleMock.js",
        "\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$": "<rootDir>/lib/js/jest/fileMock.js"
    }
}

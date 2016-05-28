var fs      = require('fs');
var path    = require('path');
var webpack = require("webpack");

var ENTRIES = {
    index: "./standalone.js"
}

module.exports = {
    cache: false,
    entry: ENTRIES,
    output: {
        path: path.join(__dirname, "../client/lanes/vendor/standalone"),
        filename: "[name].js"
    }
};

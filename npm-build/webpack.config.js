// A WIP: http://webpack.github.io/docs/webpack-for-browserify-users.html

var fs      = require('fs');
var path    = require('path');
var webpack = require("webpack");
var ExtractTextPlugin = require("extract-text-webpack-plugin");
var CommonsChunkPlugin = require("webpack/lib/optimize/CommonsChunkPlugin");

module.exports = {
    cache: false,
    entry: {
        base: "./base.js",
        grid: "./grid.js",
        select: "./select.js",
        development: "./development.js"
    },
    'resolve': {
        'alias': {
            'underscore': 'lodash'
        }
    },
    output: {
        path: path.join(__dirname, "../client/lanes/vendor/"),
        filename: "[name].js"
    },
    plugins: [
        new CommonsChunkPlugin("commons.js"),
        new ExtractTextPlugin("[name].scss")
    ],
    module: {
        loaders: [
            { test: /\.css$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader") }
        ]
    }
};

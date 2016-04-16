var fs      = require('fs');
var path    = require('path');
var webpack = require("webpack");
var ExtractTextPlugin = require("extract-text-webpack-plugin");
var CommonsChunkPlugin = require("webpack/lib/optimize/CommonsChunkPlugin");

var buildEnv = process.env.BUILD_ENV || 'development';
var COMMONS = "commons";
var SCRIPTS = {
    base: "./base.js",
    widgets: "./react-widgets.js",
    toggle: "./react-toggle.js",
    calendar: "./calendar.js",
}

var ENTRIES = {};
for (key in SCRIPTS){
    ENTRIES[ key ] = SCRIPTS[key];
}
if (buildEnv === 'development') {
    ENTRIES['helpers'] = "./development.js";
}

module.exports = {
    cache: false,
    entry: ENTRIES,
    output: {
        path: path.join(__dirname, "../client/lanes/vendor/", buildEnv),
        filename: "[name].js"
    },
    resolve: {
        alias: {
            underscore: 'lodash',
            react: path.resolve('./node_modules/react'),
            'react-dom': path.resolve('./node_modules/react-dom')
        }
    },
    plugins: [
        new webpack.optimize.DedupePlugin(),
        new CommonsChunkPlugin({name: COMMONS, minChunks: 2}),
        new ExtractTextPlugin("../styles/[name].scss"),
        new webpack.DefinePlugin({
            'process.env': { 'NODE_ENV': JSON.stringify(buildEnv) }
        })
    ],
    module: {
        loaders: [
            { test: /\.gif$/, loader: "url-loader?mimetype=image/gif" },
            { test: /\.(png|woff|woff2|eot|ttf|svg)/, loader: "file-loader?name=[name].[ext]"  },
            { test: /\.less$/, loader: ExtractTextPlugin.extract("style-loader",
                                                                 "css-loader!less-loader") },
            { test: /\.scss$/, loader: ExtractTextPlugin.extract("raw-loader?name=[name].scss") },

            { test: /\.css$/,  loader: ExtractTextPlugin.extract("style-loader",
                                                                 "css-loader") }
        ]
    }
};

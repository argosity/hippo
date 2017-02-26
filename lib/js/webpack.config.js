// Responsible for reporting status back to webpack-driver
const WebpackDriverStatusPlugin = require('./webpack-status-plugin.js');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');
const  path = require('path');
const roots = process.env.LANES_EXT_ROOTS || './client';
const generated_dir = process.env.LANES_GENERATED_DIR;

module.exports = {

    entry: {
        lanes: [
            'react-hot-loader/patch',
            "lanes/entry.js",
        ],
    },
    output: {
        path: __dirname,
        publicPath: '/',
        filename: "lanes.js",
    },
    resolve: {
        modules: roots.split(',').concat([
            'node_modules',
            process.env.LANES_GENERATED_DIR,
        ]),
        extensions: ['.js', '.jsx'],
    },
    module: {
        rules: [
            { test: /\.css$/, use: ['style-loader', 'css-loader'] },
            { test: /\.jsx?$/, exclude: /node_modules/, loader: 'babel-loader' },
            { test: /\.scss$/, use: [
                'style-loader',
                'css-loader',
                {
                    loader: 'sass-loader',
                    options: {
                        includePaths: [ path.resolve('./node_modules'), ],
                    },
                },
            ] },
        ]

    },
    devtool: 'source-map',
    plugins: [
        new WebpackDriverStatusPlugin(),
        new webpack.optimize.CommonsChunkPlugin({
            name: 'vendor', minChunks: Infinity, filename: '[name].[hash].js',
        }),
        new HtmlWebpackPlugin({
            title: 'My App',
            filename: 'index.html',
            template: generated_dir + '/root-view.tmpl.html'
        }),
        new webpack.DefinePlugin({
            'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development')
        }),
    ],
    node: {
        fs: 'empty'
    },
    devServer: {
        hot: true,
        inline: true,
        port: 8889,
        historyApiFallback: true,
        proxy: [{
            context: '/api',
            target: 'http://localhost:4567',
        }],
        stats: {
            colors: true,
            hash: false,
            version: false,
            timings: false,
            assets: false,
            chunks: false,
            modules: false,
            reasons: false,
            children: false,
            source: false,
            errors: false,
            errorDetails: false,
            warnings: false,
            publicPath: false
        }
    }
};

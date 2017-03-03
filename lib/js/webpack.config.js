// Responsible for reporting status back to webpack-driver
const HtmlWebpackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');
const path = require('path');
// const roots = process.env.LANES_EXT_ROOTS || './client';
// const controlling_root = process.env.LANES_CONTROLLER_DIR;
        // roots.split(',').concat([
        //     'node_modules',
        //     generated_dir,
        // ]),

const config = {
    entry: {
        lanes: [
            'react-hot-loader/patch',
            'lanes/entry.js',
        ],
    },
    output: {
        path: __dirname,
        publicPath: '/',
        filename: 'lanes.js',
    },
    resolve: {
        modules: process.env.LANES_MODULES.split(':'),
        extensions: ['.js', '.jsx'],
    },
    module: {
        rules: [
            { test: /\.css$/, use: ['style-loader', 'css-loader'] },
            { loader: 'babel-loader', test: /\.jsx?$/, exclude: /node_modules/ },
            { test: /\.scss$/,
                use: [
                    'style-loader',
                    'css-loader',
                    {
                        loader: 'sass-loader',
                        options: {
                            includePaths: [path.resolve('./node_modules')],
                        },
                    },
                ],
            },
        ],
    },
    devtool: 'source-map',
    plugins: [
        new webpack.optimize.CommonsChunkPlugin({
            name: 'vendor', minChunks: Infinity, filename: '[name].[hash].js',
        }),
        new HtmlWebpackPlugin({
            title: 'My App',
            filename: 'index.html',
            template: `${process.env.GENERATED_CONFIG_DIR}/root-view.tmpl.html`,
        }),
        new webpack.DefinePlugin({
            'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development'),
        }),
    ],
    node: {
        fs: 'empty',
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
            publicPath: false,
        },
    },
};

// console.log(config)

module.exports = config;
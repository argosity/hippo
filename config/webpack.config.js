const HtmlWebpackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');
const path = require('path');

const config = {
    entry: {
        hippo: [
            'react-hot-loader/patch',
            '<%= "#{Hippo::Extensions.controlling.identifier}/index.js" %>',
        ],
    },
    output: {
        path: __dirname,
        publicPath: '/',
        filename: '<%= Hippo::Extensions.controlling.identifier + '.js' %>',
    },
    resolve: {
        modules: ["<%= module_paths.join('","') %>"],
        extensions: ['.js', '.jsx'],
    },
    module: {
        rules: [
            { test: /\.css$/, use: ['style-loader', 'css-loader'] },
            {
                loader: 'babel-loader',
                test: /\.jsx?$/,
                exclude: /node_modules/,
                options: {
                    plugins: [
                        'react-hot-loader/babel',
                        'babel-plugin-transform-decorators-legacy',
                        'babel-plugin-transform-class-properties',
                        'babel-plugin-transform-function-bind',
                        'babel-plugin-transform-react-jsx',
                        'babel-plugin-transform-runtime',
                    ].map(require.resolve),
                    presets: [
                        [require.resolve('babel-preset-es2015'), { modules: false }],
                        require.resolve('babel-preset-react'),
                        require.resolve('babel-preset-stage-1'),
                    ],
                },
            },
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
            filename: 'index.html',
            template: '<%= directory.join('index.html') %>',
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
            target: 'http://localhost:9292',
        }],
        stats: {
            colors: true,
            profile: true,
            hash: false,
            version: false,
            timings: false,
            assets: true,
            chunks: false,
            modules: false,
            reasons: true,
            children: false,
            source: true,
            errors: true,
            errorDetails: false,
            warnings: true,
            publicPath: false,
        },
    },
};

// console.log(config)

module.exports = config;

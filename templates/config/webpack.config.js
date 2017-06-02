const CompressionPlugin = require("compression-webpack-plugin");
const webpack = require('webpack');
const path = require('path');

const entries = {
    app: [
        '<%= identifier %>/index.js',
    ],
};

<%% unless Hippo.env.production? -%>
    for (var key in entries) {
        entries[key].unshift('react-hot-loader/patch');
    }
<%% end -%>

const config = {
    entry: entries,
    output: {
        path: '<%%= config_directory.join('..','public', 'assets') %>',
        publicPath: '<%%= Hippo.env.production? ? "https://assets.#{Hippo.config.website_domain}/assets/" : 'http://test.hippo.dev:8889/assets/' %>',
        filename: '[name]-[hash].js',
    },
    resolve: {
        modules: [
            "<%%= Hippo::Extensions.client_module_paths.join('","') %>",
            "<%%= generated_directory.to_s %>",
        ],
        extensions: ['.js', '.jsx'],
    },
    module: {
        rules: [
            {
                test: /\.css$/,
                use: [ 'style-loader',  'css-loader' ]
            },
            {
                test: /\.(jpg|png|svg)$/,
                loader: 'url-loader',
                options: {
                    limit: 25000,
                },
            },
            {
                loader: 'babel-loader',
                test: /\.jsx?$/,
                exclude: /node_modules/,
                options: {
                    plugins: [
                        'react-hot-loader/babel',
                        'babel-plugin-lodash',
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
                    'resolve-url-loader',
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
        new webpack.DefinePlugin({
            'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development'),
        }),
<%% if Hippo.env.production? %>
        new webpack.optimize.UglifyJsPlugin(), //minify everything
        new webpack.optimize.AggressiveMergingPlugin(), //Merge chunks
        new webpack.optimize.OccurrenceOrderPlugin(), // use smallest id for most used chuncks
        new CompressionPlugin({
          asset: "[path].gz[query]",
          algorithm: "gzip",
          test: /\.(js|html)$/,
          threshold: 10240,
          minRatio: 0.8
        }),
<%% else %>
        new webpack.NamedModulesPlugin(),
<%% end %>
    ],
    node: {
        fs: 'empty',
    },
    devServer: {
        hot: true,
        inline: true,
        port: 8889,
        contentBase: './public',
        historyApiFallback: {
            index: '/assets/app.html'
        },
        headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, PATCH, OPTIONS",
            "Access-Control-Allow-Headers": "X-Requested-With, content-type, Authorization"
        },
        disableHostCheck: true,
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

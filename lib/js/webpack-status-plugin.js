"use strict";

var webpack = require("webpack");

function DashboardPlugin(options) {
    this.options = options;
}

function log(type, value) {
    console.log('STATUS:', JSON.stringify({type, value}));
}

DashboardPlugin.prototype.apply = function(compiler) {
    var timer;

    if ( compiler.options.devServer ) {
        let {port, host, outputPath} = compiler.options.devServer;
        log("dev-server", { port, host, outputPath });
    }

    // compiler.apply(new webpack.ProgressPlugin(function (percent, msg) {
    //     log("compile", {
    //         "progress":  percent,
    //         "operation": msg,
    //         "ms": Date.now() - timer
    //     });
    // }));

    compiler.plugin("compile", function() {
        timer = Date.now();
        log("compile", {
            "progress":  0,
            "operation": "idle"
        })
    });

    compiler.plugin("invalid", function() {
        log("status", "invalid");
    });

    compiler.plugin("failed-module", function(module) {
        log("failed-module", module);
    });
    compiler.plugin("done", function(stats) {
        if (stats.compilation.errors && stats.compilation.errors.length){
            log("status", "invalid");
            for(var i = 0; i < stats.compilation.errors.length; i++){
                var err = stats.compilation.errors[i];
                log("error", {
                    name: err.name, message: err.message,
                    resource: err.module ? err.module.resource : ''
                });
            }
        } else {
            log("status", "success");
        }
    });

    compiler.plugin("failed", function() {
        log("status", "failed");
    });

    compiler.plugin("valid", function() {
        log("status", "valid");
    });

    compiler.plugin("after-emit", function(compilation, callback) {
        for (var k in compilation.assets){
            if(!compilation.assets[k].parents){
                log("asset", {name: k, size: compilation.assets[k].size()});
            }
        }
        callback();
    });

}

module.exports = DashboardPlugin;

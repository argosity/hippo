#!/usr/bin/env coffee

browserify = require 'browserify'
fs         = require 'fs'
path       = require 'path'

browserify({ debug: false })
    .require(require.resolve('./template.js'), { entry: true })
    .bundle()
    .pipe(fs.createWriteStream(path.join(__dirname, '../client/lanes/vendor/packaged.js'), 'utf8'))

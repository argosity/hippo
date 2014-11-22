#!/usr/bin/env coffee

browserify = require 'browserify'
fs         = require 'fs'
path       = require 'path'
#exposify   = require 'exposify'

# configure what we want to expose
#exposify.config = { jquery: 'jQuery', underscore: '_' }

browserify({ debug: true })
#    .transform(exposify)
    .require(require.resolve('./template.js'), { entry: true })
    .bundle()
    .pipe(fs.createWriteStream(path.join(__dirname, '../client/vendor/packaged.js'), 'utf8'))

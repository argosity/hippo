#!/usr/bin/env coffee

browserify = require 'browserify'
fs         = require 'fs'
path       = require 'path'

compile = (name) ->
    console.log "compiling #{name}"
    ignore = if name = 'base' then '' else 'react'
    dest = path.join(__dirname, "../client/lanes/vendor/#{name}.js")
    browserify({ debug: false })
        .exclude(ignore)
        .require(require.resolve("./#{name}"), { entry: true })
        .bundle()
        .pipe(fs.createWriteStream(dest, 'utf8'))


for name in ['base', 'react-datagrid']
    compile(name)

###
Copyright (C) 2013 RoboIME

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.
###

config = require("config")

module.exports = (grunt) ->

  # Automatically load grunt tasks
  require('load-grunt-tasks')(grunt)

  # Project configuration.
  grunt.initConfig

    # Metadata.
    pkg: grunt.file.readJSON("package.json")

    clean: ["public"]

    develop:
      server:
        file: "src/server.coffee"
        cmd: "coffee"
      tunneler:
        file: "src/tunneler.coffee"
        cmd: "coffee"

    watch:
      server:
        files: ["src/**/*.coffee"]
        tasks: ["develop:server"]
        options:
          nospawn: true

      tunneler:
        files: ["src/tunneler.coffee", "src/proto/**"]
        task: ["develop:tunneler"]

      appStyle:
        files: ["app/**/*.styl"]
        tasks: ["stylus"]
        options:
          livereload: true

      appHtml:
        files: ["app/**/*.jade"]
        tasks: ["jade"]
        options:
          livereload: true

      appScript:
        #files: ["app/**/*.coffee"]
        #tasks: ["browserify"]
        files: ["public/*.js"]
        options:
          livereload: true

    bower:
      install:
        options:
          targetDir: "public/lib"
          layout: (type) ->
            type or "misc"
          install: true
          verbose: false
          cleanTargetDir: true
          cleanBowerDir: false

    browserify:
      client:
        src: "app/client.coffee"
        dest: "public/client.js"

      logworker:
        src: "app/logworker.coffee"
        dest: "public/logworker.js"

      options:
        transform: [
          "coffeeify"
          #"brfs"
          #"workerify"
        ]
        watch: true
        bundleOptions:
          debug: true
        browserifyOptions:
          extensions: [".coffee"]
          ignoreGlobals: true

    copy:
      app_src:
        expand: true
        src: "app/**/*.coffee"
        dest: "public/"
      src_protos:
        expand: true
        cwd: "src/protos/"
        src: "*.proto"
        dest: "public/protos/"
      assets:
        expand: true
        cwd: "assets/"
        src: "**/*"
        dest: "public/"

    jade:
      app:
        options:
          pretty: true
          data: ->
            config: config
        files:
          "public/index.html": "app/index.jade"

    stylus:
      compile:
        options:
          linenos: true
        files:
          "public/style.css": "app/style.styl"

    "gh-pages":
      options:
        base: "public"
      src: ["**"]

    nodewebkit:
      options:
        #version: "0.9.2"
        build_dir: "./build"
        #keep_nw: true
        win: config.package.win
        mac: config.package.osx
        linux32: config.package.linux32
        linux64: config.package.linux64
      src: [
        "./AUTHORS"
        "./CNAME"
        "./Gruntfile.coffee"
        "./LICENSE"
        "./Procfile"
        "./README.md"
        "./app"
        "./assets"
        "./bin"
        "./bower.json"
        "./config"
        './node_modules/**'
        '!./node_modules/*grunt*/**'
        '!./node_modules/coffeify/**'
        "./package.json"
        "./public/**"
        "./src/**"
      ]

  # Default task is compiling
  grunt.registerTask "app", ["browserify", "jade", "stylus", "copy"]
  grunt.registerTask "default", ["bower", "app"]
  grunt.registerTask "run", ["default", "develop:server", "watch"]
  grunt.registerTask "tunneler", ["develop:tunneler", "watch:tunneler"]
  grunt.registerTask "publish", ["default", "gh-pages"]
  grunt.registerTask "package", ["default", "nodewebkit"]

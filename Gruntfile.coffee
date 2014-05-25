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

module.exports = (grunt) ->

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

      app:
        files: ["app/**/*"]
        tasks: ["app"]
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

      options:
        transform: [
          "coffeeify"
          #"brfs"
          #"workerify"
        ]
        extension: ".coffee"
        ignoreGlobals: true
        bundleOptions:
          debug: true

    copy:
      app_src:
        expand: true
        src: "app/**/*.coffee"
        dest: "public/"
      app_css:
        expand: true
        cwd: "app/"
        src: "**/*.css"
        dest: "public/"
      src_protos:
        expand: true
        cwd: "src/protos/"
        src: "*.proto"
        dest: "public/protos/"

    jade:
      app:
        options:
          pretty: true
          data: ->
            config: require("config")
        files:
          "public/index.html": "app/index.jade"

  # These plugins provide necessary tasks.
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-develop"
  grunt.loadNpmTasks "grunt-bower-task"
  grunt.loadNpmTasks "grunt-browserify"
  grunt.loadNpmTasks "grunt-contrib-jade"

  # Default task is compiling
  grunt.registerTask "app", ["browserify", "jade", "copy"]
  grunt.registerTask "default", ["bower", "app"]
  grunt.registerTask "run", ["default", "develop:server", "watch"]
  grunt.registerTask "tunneler", ["develop:tunneler", "watch:tunneler"]

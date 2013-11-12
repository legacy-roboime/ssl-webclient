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

join = require("path").join

module.exports = (grunt) ->
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-develop"
  grunt.loadNpmTasks "grunt-bower-task"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-jade"

  grunt.initConfig
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

    coffee:
      app:
        files:
          "public/client.js": "app/**/*.coffee"
        options:
          sourceMap: true

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
            livereload: require("config").livereload
        files:
          "public/index.html": "app/index.jade"


  # Default task is compiling
  grunt.registerTask "app", ["coffee", "jade", "copy"]
  grunt.registerTask "default", ["bower", "app"]
  grunt.registerTask "run", ["default", "develop:server", "watch"]
  grunt.registerTask "tunneler", ["develop:tunneler", "watch:tunneler"]

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
config = require("config")

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

    #copy:
    #  assets:
    #    expand: true
    #    cwd: "assets/"
    #    src: ["**"]
    #    dest: "static/assets/"

    develop:
      server:
        file: "src/server.coffee"
        cmd: "coffee"
      tunneler:
        file: "src/tunneler.coffee"
        cmd: "coffee"

    watch:
      server:
        files: ["src/server.coffee"]
        tasks: ["develop:server"]
        options:
          nospawn: true

      tunneler:
        files: ["src/tunneler.coffee", "src/proto/**"]
        task: ["develop:tunneler"]

      app:
        files: ["app/**/*"]
        tasks: ["compile", "coffee", "jade"]
        options:
          livereload: true

    bower:
      install:
        options:
          targetDir: "public/lib"
          layout: (type) ->
            type
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

    jade:
      app:
        options:
          pretty: true
        files:
          "public/index.html": "app/app.jade"


  # Default task is compiling
  grunt.registerTask "default", ["bower", "coffee", "jade"]
  grunt.registerTask "run", ["default", "develop:server", "watch"]
  grunt.registerTask "tunneler", ["develop:tunneler", "watch:tunneler"]

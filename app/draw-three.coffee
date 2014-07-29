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

#numeral = require("numeral")
THREE = require("three")
$ = require("jquery")
{options, default_geometry_field, cmd2txt, stg2txt} = require("./draw")

inner_width = 7500
inner_height = 5500


class Painter
  constructor: (elem) ->
    @detection = null
    @drawDetection = false
    @geometry = null
    @drawGeometry = false
    @referee = null
    @drawReferee = false
    @timestamp = null

    @scene = new THREE.Scene()

    @camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 10000)
    @camera.position.z = 1000

    geometry = new THREE.BoxGeometry(200, 200, 200)
    material = new THREE.MeshBasicMaterial({ color: 0xff0000, wireframe: true })

    @mesh = new THREE.Mesh(geometry, material)
    @scene.add(@mesh)

    @renderer = new THREE.CanvasRenderer()
    @renderer.setSize(window.innerWidth, window.innerHeight)

    @container = $(elem)
    @container.append(@renderer.domElement)
    global.jQuery = global.$ = $

    # draw default sized field
    #drawField(default_geometry_field)
    @start()

  _draw: ->
    if @drawField
      @drawField = false
      drawField @geometry.field
    if @drawReferee
      @drawReferee = false
      drawReferee @referee
    if @drawDetection
      @drawDetection = false
      for robot in @detection.robots_yellow
        robot.timestamp = @detection.t_capture
        robot.camera_id = @detection.camera_id
        robot.frame_number = @detection.frame_number
        robot.color = "yellow"
      for robot in @detection.robots_blue
        robot.timestamp = @detection.t_capture
        robot.camera_id = @detection.camera_id
        robot.frame_number = @detection.frame_number
        robot.color = "blue"
      for ball in @detection.balls
        ball.timestamp = @detection.t_capture
        ball.camera_id = @detection.camera_id
        ball.frame_number = @detection.frame_number
      #drawRobots @detection.robots_yellow, "yellow", @detection.t_capture, @detection.camera_id, @detection.frame_number
      #drawRobots @detection.robots_blue, "blue", @detection.t_capture, @detection.camera_id, @detection.frame_number
      #drawBalls  @detection.balls, @detection.t_capture, @detection.camera_id, @detection.frame_number

    @renderer.render(@scene, @camera)
    requestAnimationFrame(=> @_draw()) unless @_stop

  updateVision: (packet, @timestamp=new Date()) ->

    if packet.detection
      unless packet.detection.camera_id in options.ignore_cams
        @detection = packet.detection
        @drawDetection = true

    if packet.geometry
      @geometry = packet.geometry
      @drawField = true

    @mesh.rotation.x += 0.01
    @mesh.rotation.y += 0.02

    #@_draw()

  updateReferee: (@referee, @timestamp=new Date()) ->
    @drawReferee = true

  hide: -> @container.addClass("hide")
  show: -> @container.removeClass("hide")

  stop: -> @_stop = true
  start: ->
    @_stop = false
    @_draw()

exports.Painter = Painter

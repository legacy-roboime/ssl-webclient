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

drawField = ->

  # Draw green on field
  canvas.drawRect
    fillStyle: colors.dark_green
    x: 0
    y: 0
    width: geometry.length + 2 * geometry.border
    height: geometry.width + 2 * geometry.border
    fromCenter: false

  # Draw outside perimeter
  canvas.drawRect
    strokeStyle: colors.white
    strokeWidth: geometry.line_width
    x: geometry.border
    y: geometry.border
    width: geometry.length
    height: geometry.width
    fromCenter: false

  # Draw midball
  canvas.drawArc
    strokeStyle: colors.white
    strokeWidth: geometry.line_width
    x: geometry.border + geometry.length / 2
    y: geometry.border + geometry.width / 2
    radius: geometry.center_radius

  # Draw midline
  canvas.drawLine
    strokeStyle: colors.white
    strokeWidth: geometry.line_width
    x1: geometry.border + geometry.length / 2
    y1: geometry.border
    x2: geometry.border + geometry.length / 2
    y2: geometry.border + geometry.width

  # Draw left defense area
  canvas.drawArc
    strokeStyle: colors.white
    strokeWidth: geometry.line_width
    x: geometry.border
    y: geometry.border + geometry.width / 2 + geometry.defense_stretch / 2
    radius: geometry.defense_radius
    start: 90
    end: 180

  canvas.drawArc
    strokeStyle: colors.white
    strokeWidth: geometry.line_width
    x: geometry.border
    y: geometry.border + geometry.width / 2 - geometry.defense_stretch / 2
    radius: geometry.defense_radius
    start: 0
    end: 90

  canvas.drawLine
    strokeStyle: colors.white
    strokeWidth: geometry.line_width
    x1: geometry.border + geometry.defense_radius
    y1: geometry.border + geometry.width / 2 - geometry.defense_stretch / 2
    x2: geometry.border + geometry.defense_radius
    y2: geometry.border + geometry.width / 2 + geometry.defense_stretch / 2

  # Draw right defense area
  canvas.drawArc
    strokeStyle: colors.white
    strokeWidth: geometry.line_width
    x: geometry.length + geometry.border
    y: geometry.border + geometry.width / 2 + geometry.defense_stretch / 2
    radius: geometry.defense_radius
    start: 180
    end: 270

  canvas.drawArc
    strokeStyle: colors.white
    strokeWidth: geometry.line_width
    x: geometry.length + geometry.border
    y: geometry.border + geometry.width / 2 - geometry.defense_stretch / 2
    radius: geometry.defense_radius
    start: 270
    end: 0

  canvas.drawLine
    strokeStyle: colors.white
    strokeWidth: geometry.line_width
    x1: geometry.length + geometry.border - geometry.defense_radius
    y1: geometry.border + geometry.width / 2 - geometry.defense_stretch / 2
    x2: geometry.length + geometry.border - geometry.defense_radius
    y2: geometry.border + geometry.width / 2 + geometry.defense_stretch / 2

  #draw left goal
  canvas.drawLine

    # Todo: change this
    strokeStyle: colors.yellow
    strokeWidth: geometry.line_width
    x1: geometry.border
    y1: geometry.border + geometry.width / 2 - geometry.goal_width / 2
    x2: geometry.border - geometry.goal_depth
    y2: geometry.border + geometry.width / 2 - geometry.goal_width / 2
    x3: geometry.border - geometry.goal_depth
    y3: geometry.border + geometry.width / 2 + geometry.goal_width / 2
    x4: geometry.border
    y4: geometry.border + geometry.width / 2 + geometry.goal_width / 2

  #draw right goal
  canvas.drawLine

    # Todo: change this
    strokeStyle: colors.blue
    strokeWidth: geometry.line_width
    x1: geometry.length + geometry.border
    y1: geometry.border + geometry.width / 2 - geometry.goal_width / 2
    x2: geometry.length + geometry.border + geometry.goal_depth
    y2: geometry.border + geometry.width / 2 - geometry.goal_width / 2
    x3: geometry.length + geometry.border + geometry.goal_depth
    y3: geometry.border + geometry.width / 2 + geometry.goal_width / 2
    x4: geometry.length + geometry.border
    y4: geometry.border + geometry.width / 2 + geometry.goal_width / 2

drawRobots = (robots, color) ->
  robots.forEach (robot) ->
    orientation = 270 - robot.orientation / 3.14159265359878 * 180
    x = -robot.x / geometry.scaling + geometry.length / 2 + geometry.border
    y = robot.y / geometry.scaling + geometry.width / 2 + geometry.border
    canvas.drawArc

      # Todo: change this
      fillStyle: color
      x: x
      y: y
      radius: geometry.robot_radius
      start: orientation + geometry.robot_kicker_arc
      end: orientation - geometry.robot_kicker_arc

    canvas.drawText
      fillStyle: colors.white
      strokeStyle: colors.black
      strokeWidth: 1
      x: x
      y: y
      fontSize: 8
      fontFamily: "Verdana, sans-serif"
      text: robot.robot_id


drawBalls = (balls) ->
  balls.forEach (ball) ->
    canvas.drawArc

      # Todo: change this
      fillStyle: colors.orange
      x: -ball.x / geometry.scaling + geometry.length / 2 + geometry.border
      y: ball.y / geometry.scaling + geometry.width / 2 + geometry.border
      radius: geometry.ball_radius

updateRefereeState = (referee) ->
  # Time voodoo: converting ticks to minutes:seconds
  $('#time_left').html "#{~~(referee.stage_time_left / (60 * 1000000))}:#{Math.abs(~~(referee.stage_time_left / 1000000)) % 60}" if referee.stage_time_left != null
  $('#team_yellow #team_name').html referee.yellow.name
  $('#team_yellow #score').html referee.yellow.score
  $('#team_blue #team_name').html referee.blue.name
  $('#team_blue #score').html referee.blue.score

canvas = $("#main_canvas")
geometry =
  width: 400
  length: 600
  border: 50
  line_width: 2
  center_radius: 50
  defense_radius: 50
  defense_stretch: 35
  goal_width: 70
  goal_depth: 18
  robot_radius: 9
  ball_radius: 2.15
  scaling: 10
  robot_kicker_arc: 45.5

colors =
  dark_green: "#008000"
  yellow: "#FFFF00"
  orange: "#FFBB00"
  blue: "#0000FF"
  white: "#FFFFFF"
  black: "#000000"


# Run once DOM is ready. Setup socket events and fire away.
$ ->
  socket = io.connect()
  canvas = $("#main_canvas")
  drawField()
  socket.on "ssl_packet", (packet) ->
    drawField()
    data = packet.detection
    return if typeof data is `undefined`
    drawRobots data.robots_yellow, colors.yellow
    drawRobots data.robots_blue, colors.blue
    drawBalls data.balls

  socket.on "ssl_refbox_packet", (packet) ->
    updateRefereeState packet

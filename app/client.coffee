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

svg = do ->
  _svg = d3.select("#field").append("svg")
    #.attr("width", 650)
    #.attr("height", 450)
    .attr("viewBox", "0 0 6500 4500")
    .call(d3.behavior.zoom().scaleExtent([.75, 10]).on("zoom", ->
      #TODO maybe limit the translation?
      svg.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
    ))
  #_svg.append("g")
  #  .append("rect")
  #  .classed("grass", true)
  #  .attr("width", "100%")
  #  .attr("height", "100%")
  _svg.append("g")

default_geometry_field =
  line_width: 10
  field_length: 6000
  field_width: 4000
  boundary_width: 250
  referee_width: 500
  goal_width: 700
  goal_depth: 180
  goal_wall_width: 20
  center_circle_radius: 500
  defense_radius: 500
  defense_stretch: 350
  free_kick_from_defense_dist: 700
  penalty_spot_from_field_line_dist: 450
  penalty_line_from_spot_dist: 350

#geometry =
#  field_width: 4000
#  field_length: 6000
#  boundary_width: 500
#  line_width: 20
#  center_circle_radius: 500
#  defense_radius: 500
#  defense_stretch: 350
#  goal_width: 700
#  goal_depth: 180
#  robot_radius: 90
#  ball_radius: 21.5
#  scaling: 100
#  robot_kicker_arc: 455

drawField = (field_geometry, is_blue_left=true) ->

  g = field_geometry
  svg.append("path")
    .classed("white", true)
    .classed("field-lines", true)
    .attr("d",
      # the outsite perimeter
      """
      m #{g.boundary_width} #{g.boundary_width}
      h #{g.field_length}
      v #{g.field_width}
      h-#{g.field_length}
      v-#{g.field_width}
      m #{g.line_width} #{g.line_width}
      v #{g.field_width - 2 * g.line_width}
      h #{g.field_length - 2 * g.line_width}
      v-#{g.field_width - 2 * g.line_width}
      h-#{g.field_length - 2 * g.line_width}

      M #{g.boundary_width + g.field_length / 2 + g.line_width / 2} #{g.boundary_width}
      v #{g.field_width}
      h-#{g.line_width}
      v-#{g.field_width}
      h #{g.line_width}

      M #{g.boundary_width + g.field_length / 2} #{g.boundary_width + g.field_width / 2 - g.center_circle_radius}
      a #{g.center_circle_radius} #{g.center_circle_radius} 0 0 1 0 #{2 * g.center_circle_radius}
      a #{g.center_circle_radius} #{g.center_circle_radius} 0 0 1 0-#{2 * g.center_circle_radius}
      m 0 #{g.line_width}
      a #{g.center_circle_radius - g.line_width} #{g.center_circle_radius - g.line_width} 0 0 0 0 #{2 * (g.center_circle_radius - g.line_width)}
      a #{g.center_circle_radius - g.line_width} #{g.center_circle_radius - g.line_width} 0 0 0 0-#{2 * (g.center_circle_radius - g.line_width)}

      M #{g.boundary_width + g.field_length / 2} #{g.boundary_width + g.field_width / 2 - 1.5 * g.line_width}
      a #{1.5 * g.line_width} #{1.5 * g.line_width} 0 0 1 0 #{3 * g.line_width}
      a #{1.5 * g.line_width} #{1.5 * g.line_width} 0 0 1 0-#{3 * g.line_width}

      M #{g.boundary_width} #{g.boundary_width + g.field_width / 2 - g.defense_radius - g.defense_stretch / 2}
      a #{g.defense_radius} #{g.defense_radius} 0 0 1 #{g.defense_radius} #{g.defense_radius}
      v #{g.defense_stretch}
      a #{g.defense_radius} #{g.defense_radius} 0 0 1-#{g.defense_radius} #{g.defense_radius}
      v-#{g.line_width}
      a #{g.defense_radius - g.line_width} #{g.defense_radius - g.line_width} 0 0 0 #{g.defense_radius - g.line_width}-#{g.defense_radius - g.line_width}
      v-#{g.defense_stretch}
      a #{g.defense_radius - g.line_width} #{g.defense_radius - g.line_width} 0 0 0-#{g.defense_radius - g.line_width}-#{g.defense_radius - g.line_width}

      M #{g.boundary_width + g.field_length} #{g.boundary_width + g.field_width / 2 + g.defense_radius + g.defense_stretch / 2}
      a #{g.defense_radius} #{g.defense_radius} 0 0 1-#{g.defense_radius}-#{g.defense_radius}
      v-#{g.defense_stretch}
      a #{g.defense_radius} #{g.defense_radius} 0 0 1 #{g.defense_radius}-#{g.defense_radius}
      v #{g.line_width}
      a #{g.defense_radius - g.line_width} #{g.defense_radius - g.line_width} 0 0 0-#{g.defense_radius - g.line_width} #{g.defense_radius - g.line_width}
      v #{g.defense_stretch}
      a #{g.defense_radius - g.line_width} #{g.defense_radius - g.line_width} 0 0 0 #{g.defense_radius - g.line_width} #{g.defense_radius - g.line_width}

      M #{g.boundary_width + g.penalty_spot_from_field_line_dist - g.line_width} #{g.boundary_width + g.field_width / 2}
      a #{1 * g.line_width} #{1 * g.line_width} 0 0 1 #{2 * g.line_width} 0
      a #{1 * g.line_width} #{1 * g.line_width} 0 0 1-#{2 * g.line_width} 0

      M #{g.boundary_width + g.field_length - g.penalty_spot_from_field_line_dist - g.line_width} #{g.boundary_width + g.field_width / 2}
      a #{1 * g.line_width} #{1 * g.line_width} 0 0 1 #{2 * g.line_width} 0
      a #{1 * g.line_width} #{1 * g.line_width} 0 0 1-#{2 * g.line_width} 0

      z
      """)

  svg.append("path")
    .classed("blue", is_blue_left)
    .classed("yellow", not is_blue_left)
    .classed("field-lines", true)
    .attr("d",
      """
      M #{g.boundary_width} #{g.boundary_width + g.field_width / 2 - g.goal_width / 2 - g.goal_wall_width / 2}
      h-#{g.goal_depth + g.goal_wall_width}
      v #{g.goal_width + 2 * g.goal_wall_width}
      h #{g.goal_depth + g.goal_wall_width}
      v-#{g.goal_wall_width}
      h-#{g.goal_depth}
      v-#{g.goal_width}
      h #{g.goal_depth}
      z
      """)

  svg.append("path")
    .classed("blue", not is_blue_left)
    .classed("yellow", is_blue_left)
    .classed("field-lines", true)
    .attr("d",
      """
      M #{g.boundary_width + g.field_length} #{g.boundary_width + g.field_width / 2 - g.goal_width / 2 - g.goal_wall_width / 2}
      h #{g.goal_depth + g.goal_wall_width}
      v #{g.goal_width + 2 * g.goal_wall_width}
      h-#{g.goal_depth + g.goal_wall_width}
      v-#{g.goal_wall_width}
      h #{g.goal_depth}
      v-#{g.goal_width}
      h-#{g.goal_depth}
      z
      """)

drawRobots = (robot_data, color) ->
  robots = d3.selectAll "robot.#{color}"

  #robots.forEach (robot) ->
  #  orientation = 270 - robot.orientation / 3.14159265359878 * 180
  #  x = -robot.x / geometry.scaling + geometry.length / 2 + geometry.border
  #  y = robot.y / geometry.scaling + geometry.width / 2 + geometry.border
  #  canvas.drawArc

  #    # Todo: change this
  #    fillStyle: color
  #    x: x
  #    y: y
  #    radius: geometry.robot_radius
  #    start: orientation + geometry.robot_kicker_arc
  #    end: orientation - geometry.robot_kicker_arc

  #  canvas.drawText
  #    fillStyle: colors.white
  #    strokeStyle: colors.black
  #    strokeWidth: 1
  #    x: x
  #    y: y
  #    fontSize: 8
  #    fontFamily: "Verdana, sans-serif"
  #    text: robot.robot_id


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

# Run once DOM is ready. Setup socket events and fire away.
$ ->
  socket = io.connect()
  #canvas = $("#main_canvas")
  drawField(default_geometry_field)

  socket.on "ssl_packet", (packet) ->
    {detection, geometry} = packet

    if detection?
      drawRobots detection.robots_yellow, "yellow"
      drawRobots detection.robots_blue, "blue"
      #drawBalls detection.balls

    if geometry?
      drawField geometry.field
      #window.geo = geometry

  socket.on "ssl_refbox_packet", (packet) ->
    updateRefereeState packet

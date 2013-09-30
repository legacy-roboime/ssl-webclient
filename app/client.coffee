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

inner_width = 7200
inner_height = 5200

svg = do ->
  _svg = d3.select("#field").append("svg")
    .attr("viewBox", "-#{inner_width / 2} -#{inner_height / 2} #{inner_width} #{inner_height}")
    .attr("x", "50%")
    .attr("y", "50%")
    .call(d3.behavior.zoom()
      .scaleExtent([.75, 10])
      .on("zoom", ->
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

field_path = (g) ->
  path = ""
  path += # outer rectangle
  """
  M #{-g.field_length / 2} #{-g.field_width / 2}
  h #{g.field_length}
  v #{g.field_width}
  h-#{g.field_length}
  v-#{g.field_width}
  m #{g.line_width} #{g.line_width}
  v #{g.field_width - 2 * g.line_width}
  h #{g.field_length - 2 * g.line_width}
  v-#{g.field_width - 2 * g.line_width}
  h-#{g.field_length - 2 * g.line_width}
  """
  path += # middle line
  """
  M #{g.line_width / 2}-#{g.field_width / 2}
  v #{g.field_width}
  h-#{g.line_width}
  v-#{g.field_width}
  h #{g.line_width}
  """
  path += # center circle
  """
  M 0-#{g.center_circle_radius}
  a #{g.center_circle_radius} #{g.center_circle_radius} 0 0 1 0 #{2 * g.center_circle_radius}
  a #{g.center_circle_radius} #{g.center_circle_radius} 0 0 1 0-#{2 * g.center_circle_radius}
  m 0 #{g.line_width}
  a #{g.center_circle_radius - g.line_width} #{g.center_circle_radius - g.line_width} 0 0 0 0 #{2 * (g.center_circle_radius - g.line_width)}
  a #{g.center_circle_radius - g.line_width} #{g.center_circle_radius - g.line_width} 0 0 0 0-#{2 * (g.center_circle_radius - g.line_width)}
  """
  path += # central spot
  """
  M 0-#{1.5 * g.line_width}
  a #{1.5 * g.line_width} #{1.5 * g.line_width} 0 0 1 0 #{3 * g.line_width}
  a #{1.5 * g.line_width} #{1.5 * g.line_width} 0 0 1 0-#{3 * g.line_width}
  """
  path += # left defense area
  """
  M-#{g.field_length / 2}-#{g.defense_radius + g.defense_stretch / 2}
  a #{g.defense_radius} #{g.defense_radius} 0 0 1 #{g.defense_radius} #{g.defense_radius}
  v #{g.defense_stretch}
  a #{g.defense_radius} #{g.defense_radius} 0 0 1-#{g.defense_radius} #{g.defense_radius}
  v-#{g.line_width}
  a #{g.defense_radius - g.line_width} #{g.defense_radius - g.line_width} 0 0 0 #{g.defense_radius - g.line_width}-#{g.defense_radius - g.line_width}
  v-#{g.defense_stretch}
  a #{g.defense_radius - g.line_width} #{g.defense_radius - g.line_width} 0 0 0-#{g.defense_radius - g.line_width}-#{g.defense_radius - g.line_width}
  """
  path += # right defense area
  """
  M #{g.field_length / 2} #{g.defense_radius + g.defense_stretch / 2}
  a #{g.defense_radius} #{g.defense_radius} 0 0 1-#{g.defense_radius}-#{g.defense_radius}
  v-#{g.defense_stretch}
  a #{g.defense_radius} #{g.defense_radius} 0 0 1 #{g.defense_radius}-#{g.defense_radius}
  v #{g.line_width}
  a #{g.defense_radius - g.line_width} #{g.defense_radius - g.line_width} 0 0 0-#{g.defense_radius - g.line_width} #{g.defense_radius - g.line_width}
  v #{g.defense_stretch}
  a #{g.defense_radius - g.line_width} #{g.defense_radius - g.line_width} 0 0 0 #{g.defense_radius - g.line_width} #{g.defense_radius - g.line_width}
  """
  path += # left penalty spot
  """
  M-#{g.field_length / 2 - g.penalty_spot_from_field_line_dist - g.line_width} 0
  a #{1 * g.line_width} #{1 * g.line_width} 0 0 1 #{2 * g.line_width} 0
  a #{1 * g.line_width} #{1 * g.line_width} 0 0 1-#{2 * g.line_width} 0
  """
  path += # right penalty spot
  """
  M #{g.field_length / 2 - g.penalty_spot_from_field_line_dist - g.line_width} 0
  a #{1 * g.line_width} #{1 * g.line_width} 0 0 1 #{2 * g.line_width} 0
  a #{1 * g.line_width} #{1 * g.line_width} 0 0 1-#{2 * g.line_width} 0
  """
  path += # close it
  """
  z
  """
  # done
  path

left_goal_path = (g) ->
  """
  M-#{g.field_length / 2}-#{g.goal_width / 2 + g.goal_wall_width / 2}
  h-#{g.goal_depth + g.goal_wall_width}
  v #{g.goal_width + 2 * g.goal_wall_width}
  h #{g.goal_depth + g.goal_wall_width}
  v-#{g.goal_wall_width}
  h-#{g.goal_depth}
  v-#{g.goal_width}
  h #{g.goal_depth}
  z
  """
right_goal_path = (g) ->
  """
  M #{g.field_length / 2}-#{g.goal_width / 2 + g.goal_wall_width / 2}
  h #{g.goal_depth + g.goal_wall_width}
  v #{g.goal_width + 2 * g.goal_wall_width}
  h-#{g.goal_depth + g.goal_wall_width}
  v-#{g.goal_wall_width}
  h #{g.goal_depth}
  v-#{g.goal_width}
  h-#{g.goal_depth}
  z
  """

robot_radius = 90
robot_front_cut = 65

robot_path = (r) ->
  """
  M #{r.x.toFixed(4)} #{(-r.y).toFixed(4)}
  m #{robot_front_cut} #{Math.sqrt(robot_radius * robot_radius - robot_front_cut * robot_front_cut).toFixed(4)}
  a #{robot_radius} #{robot_radius} 0 1 1 0-#{2 * robot_front_cut}
  z
  """

robot_transform = (r) ->
  "rotate(#{(180 * r.orientation / Math.PI).toFixed(4)}, #{r.x.toFixed(4)}, #{(-r.y).toFixed(4)})"

ball_radius = 21.5

robot_label = (r) ->
  r.robot_id

drawField = (field_geometry, is_blue_left=true) ->

  svg.select(".field-line")
    .datum(field_geometry)
    .transition()
    .duration(750)
    .attr("d", field_path)

  svg.select(".left-goal")
    .classed("blue", is_blue_left)
    .classed("yellow", not is_blue_left)
    .datum(field_geometry)
    .transition()
    .duration(750)
    .attr("d", left_goal_path)

  svg.select(".right-goal")
    .classed("blue", not is_blue_left)
    .classed("yellow", is_blue_left)
    .datum(field_geometry)
    .transition()
    .duration(750)
    .attr("d", right_goal_path)

drawRobots = (robots, color) ->

  robot = svg.selectAll(".robot.#{color}").data(robots)

  robot
    .attr("d", robot_path)
    .attr("transform", robot_transform)

  robot.enter()
    .append("path")
    .classed("robot", true)
    .classed(color, true)
    .attr("d", robot_path)
    .attr("transform", robot_transform)

  robot.exit()
    .remove()

  label = svg.selectAll(".robot-label.#{color}").data(robots)

  label
    .text(robot_label)
    .attr("x", (r) -> r.x)
    .attr("y", (r) -> -r.y)

  label.enter()
    .append("text")
    .classed("robot-label", true)
    .classed(color, true)
    .text(robot_label)
    .attr("text-anchor", "middle")
    .attr("alignment-baseline", "central")
    .attr("x", (r) -> r.x)
    .attr("y", (r) -> -r.y)

  label.exit()
    .remove()

drawBalls = (balls) ->

  ball = svg.selectAll(".ball").data(balls)

  ball
    .attr("cx", (b) -> b.x)
    .attr("cy", (b) -> -b.y)

  ball.enter()
    .append("circle")
    .classed("ball", true)
    .attr("r", ball_radius)
    .attr("cx", (b) -> b.x)
    .attr("cy", (b) -> -b.y)

  ball.exit()
    .remove()

pad = (n, width, z) ->
  z = z || "0"
  n = n + ""
  if n.length >= width then n else new Array(width - n.length + 1).join(z) + n

# Time voodoo: converting ticks to minutes:seconds
ticks_to_time = (ticks) ->
  #TODO: time may be negative, ought to represent that
  if ticks?
    time = "#{~~(Math.abs(ticks) / (60 * 1000000))}:#{pad(Math.abs(~~(ticks / 1000000)) % 60, 2)}"
    if ticks > 0 then time else "-#{time}"
  else
    "--:--"

updateRefereeState = (referee) ->

  d3.select("#time_left").datum(referee).html((d) -> ticks_to_time(d.stage_time_left))

  yellow_team = d3.select("#team_yellow").datum(referee.yellow)
  yellow_team.select(".team_name").html((d) -> d.name)
  yellow_team.select(".score").html((d) -> d.score)

  blue_team = d3.select("#team_blue").datum(referee.blue)
  blue_team.select(".team_name").html((d) -> d.name)
  blue_team.select(".score").html((d) -> d.score)


# initialize the field
svg.append("path").classed("field-line", true)
svg.append("path").classed("left-goal", true)
svg.append("path").classed("right-goal", true)

# draw default sized field
drawField(default_geometry_field)

#socket = io.connect('http://ssl-webclient.roboime.com:8888/')
socket = io.connect()

socket.on "ssl_packet", (packet) ->
  {detection, geometry} = packet

  if detection?
    drawRobots detection.robots_yellow, "yellow"
    drawRobots detection.robots_blue, "blue"
    drawBalls detection.balls

  if geometry?
    drawField geometry.field

socket.on "ssl_refbox_packet", (packet) ->
  updateRefereeState packet

$ ->
  $("[data-toggle='tooltip']").tooltip()
  field = $("#field")[0]
  $(".fullscreen-btn").click ->
    if screenfull.enabled
      screenfull.toggle(field)

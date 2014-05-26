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

d3 = require("d3")
numeral = require("numeral")
$ = require("jquery")

inner_width = 7500
inner_height = 5500

svg = do ->
  _svg = d3.select("#field").append("svg")
    .attr("viewBox", "-#{inner_width / 2} -#{inner_height / 2} #{inner_width} #{inner_height}")
    .attr("x", "50%")
    .attr("y", "50%")
    .attr("width", "100%")
    .attr("height", "100%")
    .call(d3.behavior.zoom()
      .scaleExtent([1 / 2, 10])
      .on("zoom", ->
        #TODO maybe limit the translation?
        svg.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
      ))
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
  a #{1 * g.line_width} #{1 * g.line_width} 0 0 1-#{2 * g.line_width} 0
  a #{1 * g.line_width} #{1 * g.line_width} 0 0 1 #{2 * g.line_width} 0
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
  "rotate(#{(-180 * r.orientation / Math.PI).toFixed(4)}, #{r.x.toFixed(4)}, #{(-r.y).toFixed(4)})"

ball_radius = 21.5

robot_label = (r) ->
  r.robot_id

drawField = (field_geometry, is_blue_left=true) ->

  # spacing between lines
  r = 100
  s = field_geometry.boundary_width / r
  fw = s + field_geometry.field_width / r / 2 | 0
  fl = s + field_geometry.field_length / r / 2 | 0
  grid = svg.select(".grid")

  gh = grid.selectAll(".grid .hor-line")
    .data([-fw..fw], (d) -> d)
    .attr("x1", fl * -r)
    .attr("y1", (d) -> d * r)
    .attr("x2", fl * r)
    .attr("y2", (d) -> d * r)

  gh.enter()
    .append("line")
    .attr("class", "grid hor-line")
    .attr("x1", fl * -r)
    .attr("y1", (d) -> d * r)
    .attr("x2", fl * r)
    .attr("y2", (d) -> d * r)

  gh.exit()
    .remove()

  gv = grid.selectAll(".grid .ver-line")
    .data([-fl..fl], (d) -> d)
    .attr("x1", (d) -> d * r)
    .attr("y1", fw * -r)
    .attr("x2", (d) -> d * r)
    .attr("y2", fw * r)

  gv.enter()
    .append("line")
    .attr("class", "grid ver-line")
    .attr("x1", (d) -> d * r)
    .attr("y1", fw * -r)
    .attr("x2", (d) -> d * r)
    .attr("y2", fw * r)

  gv.exit()
    .remove()

  f = svg.datum(field_geometry)

  f.select(".field-line")
    .transition()
    .duration(750)
    .attr("d", field_path)

  f.select(".left-goal")
    .classed("blue", is_blue_left)
    .classed("yellow", not is_blue_left)
    .transition()
    .duration(750)
    .attr("d", left_goal_path)

  f.select(".right-goal")
    .classed("blue", not is_blue_left)
    .classed("yellow", is_blue_left)
    .transition()
    .duration(750)
    .attr("d", right_goal_path)

  sp = 25

  f.select(".time-left")
    .attr("x", 0)
    .attr("y", (f) -> -f.field_width / 2 - sp)

  f.select(".left-name")
    .attr("x", (f) -> -f.field_length / 2 + sp)
    .attr("y", (f) -> -f.field_width / 2 + sp)

  f.select(".right-name")
    .attr("x", (f) -> f.field_length / 2 - sp)
    .attr("y", (f) -> -f.field_width / 2 + sp)

# in miliseconds
max_screen_time = 100

# robot hover tooltip
numFormat = "0"
showTip = (text) ->
  $(".tip").html(text).show()
hideTip = ->
  $(".tip").hide()

drawRobots = (robots, color, timestamp) ->
  timestampify(robots, timestamp)

  robot = svg.selectAll(".robot.#{color}").data(robots, (d) -> d.robot_id)
  robot.select("path")
    .attr("d", robot_path)
    .attr("transform", robot_transform)
  robot.select("text")
    .text(robot_label)
    .attr("x", (r) -> r.x)
    .attr("y", (r) -> -r.y)

  g = robot.enter()
    .append("g")
    .classed("robot", true)
    .classed(color, true)
    .on("mouseover", (d) -> showTip("#{color} #{d.robot_id} (#{numeral(d.x).format(numFormat)},#{numeral(d.y).format(numFormat)})"))
    .on("mouseout", -> hideTip())
  g.append("path")
    .attr("d", robot_path)
    .attr("transform", robot_transform)
  g.append("text")
    .text(robot_label)
    .attr("x", (r) -> r.x)
    .attr("y", (r) -> -r.y)

  robot.exit()
    .filter (d) ->
      # delete if either it doesn't have a timestamp, its screen time has expired
      # or its timestamp is at the future
      not d.timestamp? or timestamp - d.timestamp > max_screen_time or d.timestamp > timestamp
    .remove()


drawBalls = (balls, timestamp) ->
  timestampify(balls, timestamp)

  ball = svg.selectAll(".ball")
    .data(balls)


  ball
    .attr("cx", (b) -> b.x)
    .attr("cy", (b) -> -b.y)

  ball.enter()
    .append("circle")
    .classed("ball", true)
    .attr("r", ball_radius)
    .attr("cx", (b) -> b.x)
    .attr("cy", (b) -> -b.y)
    .on("mouseover", (d) -> showTip("ball (#{numeral(d.x).format(numFormat)},#{numeral(d.y).format(numFormat)})"))
    .on("mouseout", -> hideTip())

  ball.exit()
    .filter (d) ->
      # delete if either it doesn't have a timestamp, its screen time has expired
      # or its timestamp is at the future
      not d.timestamp? or timestamp - d.timestamp > max_screen_time or d.timestamp > timestamp
    .remove()

drawReferee = (referee, is_blue_left) ->
  #d3.select("#time_left").datum(referee).html((d) -> ticks_to_time(d.stage_time_left))
  svg.select(".time-left").datum(referee.stage_time_left)
    .text(ticks_to_time)

  [left, right] = if is_blue_left then [referee.blue, referee.yellow] else [referee.yellow, referee.blue]

  svg.select(".left-name").datum(left)
    .text((d) -> d.name)

  svg.select(".right-name").datum(right)
    .text((d) -> d.name)

  #yellow_team = d3.select("#team_yellow").datum(referee.yellow)
  #yellow_team.select(".team_name").html((d) -> d.name)
  #yellow_team.select(".score").html((d) -> d.score)

  #blue_team = d3.select("#team_blue").datum(referee.blue)
  #blue_team.select(".team_name").html((d) -> d.name)
  #blue_team.select(".score").html((d) -> d.score)

timestampify = (data, timestamp) ->
  data.map (d) ->
    d.timestamp = timestamp
    return d

pad = (n, width, z) ->
  z = z || "0"
  n = n + ""
  if n.length >= width then n else new Array(width - n.length + 1).join(z) + n

# Time voodoo: converting ticks to minutes:seconds
#XXX: tried to use moment.js without success
ticks_to_time = (ticks) ->
  #TODO: time may be negative, ought to represent that
  if ticks?
    time = "#{~~(Math.abs(ticks) / (60 * 1000000))}:#{pad(Math.abs(~~(ticks / 1000000)) % 60, 2)}"
    if ticks > 0 then time else "-#{time}"
  else
    "--:--"

# initialize the field
svg.append("g").classed("grid", true)
svg.append("path").classed("field-line", true)
svg.append("path").classed("left-goal", true)
svg.append("path").classed("right-goal", true)
svg.append("text").classed("time-left", true)
svg.append("text").classed("team-name", true)
  .classed("left-name", true)
  .attr("text-anchor", "start")
  .attr("alignment-baseline", "hanging")
svg.append("text").classed("team-name", true)
  .classed("right-name", true)
  .attr("text-anchor", "end")
  .attr("alignment-baseline", "hanging")

# draw default sized field
drawField(default_geometry_field)

class Painter
  constructor: (@is_blue_left=false) ->
    @detection = null
    @drawDetection = false
    @geometry = null
    @drawGeometry = false
    @referee = null
    @drawReferee = false
    @timestamp = null
    @_draw()

  _draw: ->
    if @drawField
      @drawField = false
      drawField @geometry.field
    if @drawReferee
      @drawReferee = false
      drawReferee @referee, @is_blue_left
    if @drawDetection
      @drawDetection = false
      drawRobots @detection.robots_yellow, "yellow", @timestamp
      drawRobots @detection.robots_blue, "blue", @timestamp
      drawBalls  @detection.balls, @timestamp
    requestAnimationFrame => @_draw()

  updateVision: (packet, @timestamp=new Date()) ->

    if packet.detection
      @detection = packet.detection
      @drawDetection = true

    if packet.geometry
      @geometry = packet.geometry
      @drawField = true

  updateReferee: (@referee, @timestamp=new Date()) ->
    @drawReferee = true


exports.Painter = Painter

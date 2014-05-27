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

transitionDuration = 750

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
    .duration(transitionDuration)
    .attr("d", field_path)

  f.select(".left-goal")
    .classed("blue", is_blue_left)
    .classed("yellow", not is_blue_left)
    .transition()
    .duration(transitionDuration)
    .attr("d", left_goal_path)

  f.select(".right-goal")
    .classed("blue", not is_blue_left)
    .classed("yellow", is_blue_left)
    .transition()
    .duration(transitionDuration)
    .attr("d", right_goal_path)

  sp = 25

  f.select(".time-left")
    .transition()
    .duration(transitionDuration)
    .attr("x", 2)
    .attr("y", (f) -> -f.field_width / 2 - sp)

  f.select(".left-name")
    .transition()
    .duration(transitionDuration)
    .attr("x", (f) -> -f.field_length / 2 + sp)
    .attr("y", (f) -> -f.field_width / 2 + sp + vPxPerLetter)

  f.select(".right-name")
    .transition()
    .duration(transitionDuration)
    .attr("x", (f) -> f.field_length / 2 - sp)
    .attr("y", (f) -> -f.field_width / 2 + sp + vPxPerLetter)

  f.select(".left-score")
    .attr("x", (f) -> -sp)
    .attr("y", (f) -> -f.field_width / 2 + sp + vPxPerLetter)

  f.select(".right-score")
    .attr("x", (f) -> sp)
    .attr("y", (f) -> -f.field_width / 2 + sp + vPxPerLetter)

# in miliseconds
max_screen_time = 100

# robot hover tooltip
numFormat = "0"
tipBusy = false
showTip = (text) ->
  tipBusy = true
  $(".tip").html(text)

persistentText = ""
restTip = ->
  tipBusy = false
  $(".tip").html(persistentText)

persistTip = (text) ->
  persistentText = text
  $(".tip").html(text) unless tipBusy

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
    .on("mouseout", -> restTip())
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
    .on("mouseout", -> restTip())

  ball.exit()
    .filter (d) ->
      # delete if either it doesn't have a timestamp, its screen time has expired
      # or its timestamp is at the future
      not d.timestamp? or timestamp - d.timestamp > max_screen_time or d.timestamp > timestamp
    .remove()

hPxPerLetter = 156
vPxPerLetter = 250
hPxPerLetterSm = 93

drawReferee = (referee, is_blue_left) ->
  #d3.select("#time_left").datum(referee).html((d) -> ticks_to_time(d.stage_time_left))
  svg.select(".time-left").datum(referee.stage_time_left)
    .text(ticks_to_time)
    .attr("textLength", (d) -> ticks_to_time(d).length * hPxPerLetterSm)

  [right, left] = if is_blue_left then [referee.blue, referee.yellow] else [referee.yellow, referee.blue]

  svg.select(".left-name").datum(left)
    .text((d) -> d.name)
    .attr("textLength", (d) -> d.name.length * hPxPerLetter)

  svg.select(".right-name").datum(right)
    .text((d) -> d.name)
    .attr("textLength", (d) -> d.name.length * hPxPerLetter)

  svg.select(".left-score").datum(left)
    .text((d) -> d.score)

  svg.select(".right-score").datum(right)
    .text((d) -> d.score)

  persistTip("#{stg2txt(referee.stage)}: #{cmd2txt(referee.command)}")
  window.referee = referee

  #yellow_team = d3.select("#team_yellow").datum(referee.yellow)
  #yellow_team.select(".team_name").html((d) -> d.name)
  #yellow_team.select(".score").html((d) -> d.score)

  #blue_team = d3.select("#team_blue").datum(referee.blue)
  #blue_team.select(".team_name").html((d) -> d.name)
  #blue_team.select(".score").html((d) -> d.score)

cmd2txt = (c) ->
  switch c
    # All robots should completely stop moving.
    when 0 then "halt"
    # Robots must keep 50 cm from the ball.
    when 1 then "stop"
    # A prepared kickoff or penalty may now be taken.
    when 2 then "start"
    # The ball is dropped and free for either team.
    when 3 then "force start"
    # The yellow team may move into kickoff position.
    when 4 then "prepare kickoff yellow"
    # The blue team may move into kickoff position.
    when 5 then "prepare kickoff blue"
    # The yellow team may move into penalty position.
    when 6 then "prepare penalty yellow"
    # The blue team may move into penalty position.
    when 7 then "prepare penalty blue"
    # The yellow team may take a direct free kick.
    when 8 then "direct free yellow"
    # The blue team may take a direct free kick.
    when 9 then "direct free blue"
    # The yellow team may take an indirect free kick.
    when 10 then "indirect free yellow"
    # The blue team may take an indirect free kick.
    when 11 then "indirect free blue"
    # The yellow team is currently in a timeout.
    when 12 then "timeout yellow"
    # The blue team is currently in a timeout.
    when 13 then "timeout blue"
    # The yellow team just scored a goal.
    # For information only.
    # For rules compliance, teams must treat as STOP.
    when 14 then "goal yellow"
    # The blue team just scored a goal.
    when 15 then "goal blue"

stg2txt = (s) ->
  switch s
    # The first half is about to start.
    # A kickoff is called within this stage.
    # This stage ends with the NORMAL_START.
    when 0 then "pre game"
    # The first half of the normal game, before half time.
    when 1 then "first half"
    # Half time between first and second halves.
    when 2 then "half time"
    # The second half is about to start.
    # A kickoff is called within this stage.
    # This stage ends with the NORMAL_START.
    when 3 then "pre second half"
    # The second half of the normal game, after half time.
    when 4 then "second half"
    # The break before extra time.
    when 5 then "extra time break"
    # The first half of extra time is about to start.
    # A kickoff is called within this stage.
    # This stage ends with the NORMAL_START.
    when 6 then "pre extra first half"
    # The first half of extra time.
    when 7 then "extra first half"
    # Half time between first and second extra halves.
    when 8 then "extra half time"
    # The second half of extra time is about to start.
    # A kickoff is called within this stage.
    # This stage ends with the NORMAL_START.
    when 9 then "pre extra second half"
    # The second half of extra time.
    when 10 then "extra second half"
    # The break before penalty shootout.
    when 11 then "penalty shootout break"
    # The penalty shootout.
    when 12 then "penalty shootout"
    # The game is over.
    when 13 then "post game"

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
  if ticks?
    time = "#{pad(~~(Math.abs(ticks) / (60 * 1000000)), 2, " ")}:#{pad(Math.abs(~~(ticks / 1000000)) % 60, 2)}"
    if ticks > 0 then time else "-#{time}"
  else
    "--:--"

# initialize the field
svg.append("g").classed("grid", true)
svg.append("path").classed("field-line", true)
svg.append("path").classed("left-goal", true)
svg.append("path").classed("right-goal", true)
svg.append("text").classed("time-left", true)
  .attr("lengthAdjust", "spacingAndGlyphs")
svg.append("text").classed("team-name", true)
  .classed("left-name", true)
  .attr("text-anchor", "start")
  .attr("lengthAdjust", "spacingAndGlyphs")
svg.append("text").classed("team-name", true)
  .classed("right-name", true)
  .attr("text-anchor", "end")
  .attr("lengthAdjust", "spacingAndGlyphs")
svg.append("text").classed("team-name", true)
  .classed("left-score", true)
  .attr("text-anchor", "end")
svg.append("text").classed("team-name", true)
  .classed("right-score", true)
  .attr("text-anchor", "start")

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

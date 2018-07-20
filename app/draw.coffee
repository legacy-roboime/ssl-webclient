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

options =
  is_blue_left: true
  show_frame_skip: false
  show_trail: false
  #ignore_cams: [0, 1, 2, 3]
  ignore_cams: ["intel"]
  vflip: 1
  hflip: 1
  xyswitch: false

global.options = options


getx = (p) ->
  options.hflip * (if options.xyswitch then p.y else p.x)

gety = (p) ->
  -options.vflip * (if options.xyswitch then p.x else p.y)

geta = (p) ->
  a = -180 * p.orientation / Math.PI
  if options.xyswitch
    a = 90 - a
  if options.hflip is -1
    a = 180 - a
  if options.vflip is -1
    a = 360 - a
  a


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

global.svg = svg
global.d3 = d3

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

field2014_path = (g) ->
  path = ""
  for line in g.field_lines
    path +=
    """
    M #{line.p1.x} #{line.p1.y}
    L #{line.p2.x} #{line.p2.y}
    """
  for arc in g.field_arcs
    arc.a2 -= 0.001
    start_x = arc.center.x + arc.radius * Math.cos(arc.a2)
    start_y = arc.center.y + arc.radius * Math.sin(arc.a2)
    end_x = arc.center.x + arc.radius * Math.cos(arc.a1)
    end_y = arc.center.y + arc.radius * Math.sin(arc.a1)
    if (arc.a2 - arc.a1) > Math.PI
      large_arc = 1
    else
      large_arc = 0
    sweep = 0
    path +=
    """

    M #{start_x} #{start_y}
    A #{arc.radius},#{arc.radius} 0 #{large_arc},#{sweep} #{end_x},#{end_y}
    """


  path

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

field_transform = (r) ->
  if options.xyswitch
    "rotate(-90)"
  else
    "rotate(0)"

left_goal_path = (g) ->
  goal_wall_width = 20
  """
  M-#{g.field_length / 2}-#{g.goal_width / 2 + goal_wall_width / 2}
  h-#{g.goal_depth + goal_wall_width}
  v #{g.goal_width + 2 * goal_wall_width}
  h #{g.goal_depth + goal_wall_width}
  v-#{goal_wall_width}
  h-#{g.goal_depth}
  v-#{g.goal_width}
  h #{g.goal_depth}
  z
  """
right_goal_path = (g) ->
  goal_wall_width = 20

  """
  M #{g.field_length / 2}-#{g.goal_width / 2 + goal_wall_width / 2}
  h #{g.goal_depth + goal_wall_width}
  v #{g.goal_width + 2 * goal_wall_width}
  h-#{g.goal_depth + goal_wall_width}
  v-#{goal_wall_width}
  h #{g.goal_depth}
  v-#{g.goal_width}
  h-#{g.goal_depth}
  z
  """

robot_radius = 90
robot_front_cut = 65

robot_path = (r) ->
  """
  M #{getx(r).toFixed(4)} #{gety(r).toFixed(4)}
  m #{robot_front_cut} #{Math.sqrt(robot_radius * robot_radius - robot_front_cut * robot_front_cut).toFixed(4)}
  a #{robot_radius} #{robot_radius} 0 1 1 0-#{2 * robot_front_cut}
  z
  """

robot_transform = (r) ->
  "rotate(#{(geta(r)).toFixed(4)}, #{getx(r).toFixed(4)}, #{gety(r).toFixed(4)})"

ball_radius = 21.5

robot_label = (r) ->
  r.robot_id

transitionDuration = 750


drawField = (field_geometry, is_legacy) ->

  # spacing between lines
  r = 100
  s = 1 + field_geometry.boundary_width / r
  fw = s + field_geometry.field_width / r / 2 | 0
  fl = s + field_geometry.field_length / r / 2 | 0
  grid = svg.select(".grid")

  gh = grid.selectAll(".grid .hor-line")
    .data([-fw..fw], (d) -> d)
    .attr("x1", fl * -r)
    .attr("y1", (d) -> d * r)
    .attr("x2", fl * r)
    .attr("y2", (d) -> d * r)
    .attr("transform", field_transform)

  gh.enter()
    .append("line")
    .attr("class", "grid hor-line")
    .attr("x1", fl * -r)
    .attr("y1", (d) -> d * r)
    .attr("x2", fl * r)
    .attr("y2", (d) -> d * r)
    .attr("transform", field_transform)

  gh.exit()
    .remove()

  gv = grid.selectAll(".grid .ver-line")
    .data([-fl..fl], (d) -> d)
    .attr("x1", (d) -> d * r)
    .attr("y1", fw * -r)
    .attr("x2", (d) -> d * r)
    .attr("y2", fw * r)
    .attr("transform", field_transform)

  gv.enter()
    .append("line")
    .attr("class", "grid ver-line")
    .attr("x1", (d) -> d * r)
    .attr("y1", fw * -r)
    .attr("x2", (d) -> d * r)
    .attr("y2", fw * r)
    .attr("transform", field_transform)

  gv.exit()
    .remove()

  f = svg.datum(field_geometry)

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

  f.select(".left-goal")
    .classed("blue", options.is_blue_left)
    .classed("yellow", not options.is_blue_left)
    .transition()
    .duration(transitionDuration)
    .attr("d", left_goal_path)
    .attr("transform", field_transform)

  f.select(".right-goal")
    .classed("blue", not options.is_blue_left)
    .classed("yellow", options.is_blue_left)
    .transition()
    .duration(transitionDuration)
    .attr("d", right_goal_path)
    .attr("transform", field_transform)

  if is_legacy

    f.select(".field-line2010")
      .attr("visibility", "visible")
      .transition()
      .duration(transitionDuration)
      .attr("d", field_path)
      .attr("transform", field_transform)

    f.select(".field-line2014").attr("visibility", "hidden")

  else
     stroke_width = field_geometry.field_lines[0].thickness * 2
     f.select(".field-line2014")
      .attr("visibility", "visible")
      .transition()
      .duration(transitionDuration)
      .attr("d", field2014_path)
      .attr("stroke-width", stroke_width)
      .attr("transform", field_transform)
     
     f.select(".field-line2010").attr("visibility", "hidden")
max_frame_distance = 5

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

drawRobots = (robots, color, timestamp, camera_id, frame_number) ->
  robot = svg.selectAll(".active.robot.#{color}").data(robots, (d) -> d.robot_id)
  robot.select("path")
    .attr("d", robot_path)
    .attr("transform", robot_transform)
  robot.select("text")
    .text(robot_label)
    .attr("x", (r) -> getx(r))
    .attr("y", (r) -> gety(r))

  if options.show_trail
    robot
      .classed("active", false)
      .classed("inactive", true)

  g = robot.enter()
    .append("g")
    .classed("robot", true)
    .classed("active", not options.show_trail)
    .classed("inactive", options.show_trail)
    .classed(color, true)
    .on("mouseover", (d) -> showTip("#{color} #{d.robot_id} (#{numeral(d.x).format(numFormat)},#{numeral(d.y).format(numFormat)})" + if d.skill then " " + d.skill.name else ""))
    .on("mouseout", -> restTip())
  g.append("path")
    .attr("d", robot_path)
    .attr("transform", robot_transform)
  g.append("text")
    .text(robot_label)
    .attr("x", (r) -> getx(r))
    .attr("y", (r) -> gety(r))

  robot_exit = robot.exit()
    .filter (d) ->
      # delete if either it doesn't have a timestamp, its screen time has expired
      # or its timestamp is at the future, but not if it's a different camera
      Math.abs(frame_number - d.frame_number) > max_frame_distance and d.camera_id is camera_id

  if options.show_frame_skip
    robot_exit.classed("active", false)
    robot_exit.classed("inactive", true)
  else
    robot_exit.remove()


drawBalls = (balls, timestamp, camera_id, frame_number) ->

  ball = svg.selectAll(".ball.active")
    .data(balls)

  ball
    .attr("cx", (b) -> getx(b))
    .attr("cy", (b) -> gety(b))

  if options.show_trail
    ball
      .classed("active", false)
      .classed("inactive", true)

  ball.enter()
    .append("circle")
    .classed("ball", true)
    .classed("active", not options.show_trail)
    .classed("inactive", options.show_trail)
    .attr("r", ball_radius)
    .attr("cx", (b) -> getx(b))
    .attr("cy", (b) -> gety(b))
    .on("mouseover", (d) -> showTip("ball (#{numeral(d.x).format(numFormat)},#{numeral(d.y).format(numFormat)})"))
    .on("mouseout", -> restTip())

  ball_exit = ball.exit()
    .filter (d) ->
      # delete if either it doesn't have a timestamp, its screen time has expired
      # or its timestamp is at the future, but not if it's a different camera
      #(not d.timestamp? or timestamp - d.timestamp > max_screen_time or d.timestamp > timestamp) and d.camera_id isnt camera_id
      Math.abs(frame_number - d.frame_number) > max_frame_distance and d.camera_id is camera_id
  if options.show_frame_skip
    ball_exit.classed("active", false)
    ball_exit.classed("inactive", true)
  else
    ball_exit.remove()

hPxPerLetter = 156
vPxPerLetter = 250
hPxPerLetterSm = 93

drawReferee = (referee) ->
  #d3.select("#time_left").datum(referee).html((d) -> ticks_to_time(d.stage_time_left))
  svg.select(".time-left").datum(referee.stage_time_left)
    .text(ticks_to_time)
    .attr("textLength", (d) -> ticks_to_time(d).length * hPxPerLetterSm)

  [right, left] = if options.is_blue_left then [referee.blue, referee.yellow] else [referee.yellow, referee.blue]

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
svg.append("path").classed("field-line2014", true)
svg.append("path").classed("field-line2010", true)
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
drawField(default_geometry_field, true)

class Painter
  constructor: ->
    @detection = null
    @drawDetection = false
    @geometry = null
    @isLegacyGeometry = true
    @drawGeometry = false
    @referee = null
    @drawReferee = false
    @timestamp = null
    @_draw()

  _draw: ->
    if @drawField
      @drawField = false
      drawField(@geometry.field, @isLegacyGeometry)
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
      drawRobots @detection.robots_yellow, "yellow", @detection.t_capture, @detection.camera_id, @detection.frame_number
      drawRobots @detection.robots_blue, "blue", @detection.t_capture, @detection.camera_id, @detection.frame_number
      drawBalls  @detection.balls, @detection.t_capture, @detection.camera_id, @detection.frame_number
    #requestAnimationFrame => @_draw()

  updateVision2010: (packet, @timestamp=new Date()) ->

    if packet.detection
      unless packet.detection.camera_id in options.ignore_cams
        @detection = packet.detection
        @drawDetection = true

    if packet.geometry
      @geometry = packet.geometry
      @isLegacyGeometry = true
      @drawField = true

    @_draw()

  updateVision2014: (packet, @timestamp=new Date()) ->

    if packet.detection
      unless packet.detection.camera_id in options.ignore_cams
        @detection = packet.detection
        @drawDetection = true

    if packet.geometry
      @geometry = packet.geometry
      @isLegacyGeometry = false
      @drawField = true

    @_draw()

  updateReferee: (@referee, @timestamp=new Date()) ->
    @drawReferee = true


exports.Painter = Painter

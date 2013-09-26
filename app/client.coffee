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
    .attr("width", 700)
    .attr("height", 500)
    .attr("viewBox", "0 0 7000 5000")
    .call(d3.behavior.zoom().scaleExtent([.75, 10]).on("zoom", ->
      #TODO maybe limit the translation?
      svg.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
    ))
  _svg.append("g")
    .append("rect")
    .classed("grass", true)
    .attr("width", "100%")
    .attr("height", "100%")
  _svg.append("g")

geometry =
  width: 4000
  length: 6000
  border: 500
  line_width: 20
  center_radius: 500
  defense_radius: 500
  defense_stretch: 350
  goal_width: 700
  goal_depth: 180
  robot_radius: 90
  ball_radius: 21.5
  scaling: 100
  robot_kicker_arc: 455

drawField = (geometry) ->

  svg.append("path")
    .classed("white", true)
    .attr("d",
      # the outsite perimeter
      """
      m #{geometry.border} #{geometry.border}
      h #{geometry.length}
      v #{geometry.width}
      h-#{geometry.length}
      v-#{geometry.width}
      m #{geometry.line_width} #{geometry.line_width}
      v #{geometry.width - 2 * geometry.line_width}
      h #{geometry.length - 2 * geometry.line_width}
      v-#{geometry.width - 2 * geometry.line_width}
      h-#{geometry.length - 2 * geometry.line_width}

      M #{geometry.border + geometry.length / 2 + geometry.line_width / 2} #{geometry.border}
      v #{geometry.width}
      h-#{geometry.line_width}
      v-#{geometry.width}
      h #{geometry.line_width}

      M #{geometry.border + geometry.length / 2} #{geometry.border + geometry.width / 2 - geometry.center_radius}
      a #{geometry.center_radius} #{geometry.center_radius} 0 0 1 0 #{2 * geometry.center_radius}
      a #{geometry.center_radius} #{geometry.center_radius} 0 0 1 0-#{2 * geometry.center_radius}
      m 0 #{geometry.line_width}
      a #{geometry.center_radius - geometry.line_width} #{geometry.center_radius - geometry.line_width} 0 0 0 0 #{2 * (geometry.center_radius - geometry.line_width)}
      a #{geometry.center_radius - geometry.line_width} #{geometry.center_radius - geometry.line_width} 0 0 0 0-#{2 * (geometry.center_radius - geometry.line_width)}

      M #{geometry.border + geometry.length / 2} #{geometry.border + geometry.width / 2 - 1.5 * geometry.line_width}
      a #{1.5 * geometry.line_width} #{1.5 * geometry.line_width} 0 0 1 0 #{3 * geometry.line_width}
      a #{1.5 * geometry.line_width} #{1.5 * geometry.line_width} 0 0 1 0-#{3 * geometry.line_width}

      M #{geometry.border} #{geometry.border + geometry.width / 2 - geometry.defense_radius - geometry.defense_stretch / 2}
      a #{geometry.defense_radius} #{geometry.defense_radius} 0 0 1 #{geometry.defense_radius} #{geometry.defense_radius}
      v #{geometry.defense_stretch}
      a #{geometry.defense_radius} #{geometry.defense_radius} 0 0 1-#{geometry.defense_radius} #{geometry.defense_radius}
      v-#{geometry.line_width}
      a #{geometry.defense_radius - geometry.line_width} #{geometry.defense_radius - geometry.line_width} 0 0 0 #{geometry.defense_radius - geometry.line_width}-#{geometry.defense_radius - geometry.line_width}
      v-#{geometry.defense_stretch}
      a #{geometry.defense_radius - geometry.line_width} #{geometry.defense_radius - geometry.line_width} 0 0 0-#{geometry.defense_radius - geometry.line_width}-#{geometry.defense_radius - geometry.line_width}

      M #{geometry.border + geometry.length} #{geometry.border + geometry.width / 2 + geometry.defense_radius + geometry.defense_stretch / 2}
      a #{geometry.defense_radius} #{geometry.defense_radius} 0 0 1-#{geometry.defense_radius}-#{geometry.defense_radius}
      v-#{geometry.defense_stretch}
      a #{geometry.defense_radius} #{geometry.defense_radius} 0 0 1 #{geometry.defense_radius}-#{geometry.defense_radius}
      v #{geometry.line_width}
      a #{geometry.defense_radius - geometry.line_width} #{geometry.defense_radius - geometry.line_width} 0 0 0-#{geometry.defense_radius - geometry.line_width} #{geometry.defense_radius - geometry.line_width}
      v #{geometry.defense_stretch}
      a #{geometry.defense_radius - geometry.line_width} #{geometry.defense_radius - geometry.line_width} 0 0 0 #{geometry.defense_radius - geometry.line_width} #{geometry.defense_radius - geometry.line_width}

      z
      """)
    #.style("fill-rule", "evenodd")

  # Draw green on field
  #svg.append("rect")
  #  .classed("grass", true)
  #  .attr("x", -_margin)
  #  .attr("y", -_margin)
  #  .attr("width", geometry.length + 2 * geometry.border + 2 * _margin)
  #  .attr("height", geometry.width + 2 * geometry.border + 2 * _margin)

  # Draw outside perimeter
  #svg.append("rect")
  #  .classed("white-line", true)
  #  .style("stroke-width", geometry.line_width)
  #  .attr("x", geometry.border)
  #  .attr("y", geometry.border)
  #  .attr("width", geometry.length)
  #  .attr("height", geometry.width)

  # Draw central circle
  #svg.append("circle")
  #  .classed("white-line", true)
  #  .style("stroke-width", geometry.line_width)
  #  .attr("cx", geometry.border + geometry.length / 2)
  #  .attr("cy", geometry.border + geometry.width / 2)
  #  .attr("r", geometry.center_radius)

  # Draw midline
  #svg.append("line")
  #  .classed("white-line", true)
  #  .style("stroke-width", geometry.line_width)
  #  .attr("x1", geometry.border + geometry.length / 2)
  #  .attr("y1", geometry.border)
  #  .attr("x2", geometry.border + geometry.length / 2)
  #  .attr("y2", geometry.border + geometry.width)

  # Draw left defense area
  #svg.append("arc")
  #  .classed("white-line", true)
  #  .style("stroke-width", geometry.line_width)
  #  .attr("x", geometry.border)
  #  .attr("y", geometry.border + geometry.width / 2 + geometry.defense_stretch / 2)
  #  .attr("radius", geometry.defense_radius)
  #  .attr("start", 90)
  #  .attr("end", 180)
  #canvas.drawArc
  #  strokeStyle: colors.white
  #  strokeWidth: geometry.line_width

  #canvas.drawArc
  #  strokeStyle: colors.white
  #  strokeWidth: geometry.line_width
  #  x: geometry.border
  #  y: geometry.border + geometry.width / 2 - geometry.defense_stretch / 2
  #  radius: geometry.defense_radius
  #  start: 0
  #  end: 90

  #canvas.drawLine
  #  strokeStyle: colors.white
  #  strokeWidth: geometry.line_width
  #  x1: geometry.border + geometry.defense_radius
  #  y1: geometry.border + geometry.width / 2 - geometry.defense_stretch / 2
  #  x2: geometry.border + geometry.defense_radius
  #  y2: geometry.border + geometry.width / 2 + geometry.defense_stretch / 2

  ## Draw right defense area
  #canvas.drawArc
  #  strokeStyle: colors.white
  #  strokeWidth: geometry.line_width
  #  x: geometry.length + geometry.border
  #  y: geometry.border + geometry.width / 2 + geometry.defense_stretch / 2
  #  radius: geometry.defense_radius
  #  start: 180
  #  end: 270

  #canvas.drawArc
  #  strokeStyle: colors.white
  #  strokeWidth: geometry.line_width
  #  x: geometry.length + geometry.border
  #  y: geometry.border + geometry.width / 2 - geometry.defense_stretch / 2
  #  radius: geometry.defense_radius
  #  start: 270
  #  end: 0

  #canvas.drawLine
  #  strokeStyle: colors.white
  #  strokeWidth: geometry.line_width
  #  x1: geometry.length + geometry.border - geometry.defense_radius
  #  y1: geometry.border + geometry.width / 2 - geometry.defense_stretch / 2
  #  x2: geometry.length + geometry.border - geometry.defense_radius
  #  y2: geometry.border + geometry.width / 2 + geometry.defense_stretch / 2

  ##draw left goal
  #canvas.drawLine

  #  # Todo: change this
  #  strokeStyle: colors.yellow
  #  strokeWidth: geometry.line_width
  #  x1: geometry.border
  #  y1: geometry.border + geometry.width / 2 - geometry.goal_width / 2
  #  x2: geometry.border - geometry.goal_depth
  #  y2: geometry.border + geometry.width / 2 - geometry.goal_width / 2
  #  x3: geometry.border - geometry.goal_depth
  #  y3: geometry.border + geometry.width / 2 + geometry.goal_width / 2
  #  x4: geometry.border
  #  y4: geometry.border + geometry.width / 2 + geometry.goal_width / 2

  ##draw right goal
  #canvas.drawLine

  #  # Todo: change this
  #  strokeStyle: colors.blue
  #  strokeWidth: geometry.line_width
  #  x1: geometry.length + geometry.border
  #  y1: geometry.border + geometry.width / 2 - geometry.goal_width / 2
  #  x2: geometry.length + geometry.border + geometry.goal_depth
  #  y2: geometry.border + geometry.width / 2 - geometry.goal_width / 2
  #  x3: geometry.length + geometry.border + geometry.goal_depth
  #  y3: geometry.border + geometry.width / 2 + geometry.goal_width / 2
  #  x4: geometry.length + geometry.border
  #  y4: geometry.border + geometry.width / 2 + geometry.goal_width / 2

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
  drawField(geometry)

  socket.on "ssl_packet", (packet) ->
    #drawField()
    {detection} = packet
    if detection?
      drawRobots detection.robots_yellow, "yellow"
      drawRobots detection.robots_blue, "blue"
      #drawBalls detection.balls

  socket.on "ssl_refbox_packet", (packet) ->
    updateRefereeState packet

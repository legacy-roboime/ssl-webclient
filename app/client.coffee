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
max_screen_time = 30

drawRobots = (robots, color, timestamp) ->
  timestampify(robots, timestamp)

  robot = svg.selectAll(".robot.#{color}").data(robots, (d) -> d.robot_id)

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
    .filter (d) ->
      # delete if either it doesn't have a timestamp, its screen time has expired
      # or its timestamp is at the future
      not d.timestamp? or timestamp - d.timestamp > max_screen_time or d.timestamp > timestamp
    .remove()

  label = svg.selectAll(".robot-label.#{color}").data(robots, (d) -> d.robot_id)

  label
    .text(robot_label)
    .attr("x", (r) -> r.x)
    .attr("y", (r) -> -r.y)

  label.enter()
    .append("text")
    .classed("robot-label", true)
    .classed(color, true)
    .text(robot_label)
    .attr("x", (r) -> r.x)
    .attr("y", (r) -> -r.y)

  label.exit()
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

  ball.exit()
    .filter (d) ->
      # delete if either it doesn't have a timestamp, its screen time has expired
      # or its timestamp is at the future
      not d.timestamp? or timestamp - d.timestamp > max_screen_time or d.timestamp > timestamp
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

updateRefereeState = (referee, is_blue_left=true) ->

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

updateVisionState = (vision, timestamp=new Date()) ->
  {detection, geometry} = vision

  if detection?
    drawRobots detection.robots_yellow, "yellow", timestamp
    drawRobots detection.robots_blue, "blue", timestamp
    drawBalls  detection.balls, timestamp

  if geometry?
    drawField geometry.field


# initialize the field
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

# ---------------------------
# log playing stuff

# XXX: why do we need this? bug??
window.ProtoBuf = dcodeIO.ProtoBuf

class LogParser

  header = "SSL_LOG_FILE"
  vision_builder = dcodeIO.ProtoBuf.protoFromFile("protos/messages_robocup_ssl_wrapper.proto").build("SSL_WrapperPacket")
  refbox_builder = dcodeIO.ProtoBuf.protoFromFile("protos/referee.proto").build("SSL_Referee")

  constructor: (@buffer, @progress_step=10000) ->
    # SSL_LOG_FILE + version (uint32)
    @offset = header.length + 4
    @dataview = new DataView(@buffer)
    @last_progress = 0
    # rough approximation if used without caching
    @max_offset = @buffer.byteLength

    unless @check_type()
      throw new Error("Invalid file format")
    unless (ver = @check_version()) == 1
      throw new Error("Unsupported log format version #{ver}")

  check_type: ->
    decodeURIComponent(String.fromCharCode.apply(null, Array.prototype.slice.apply(new Uint8Array(@buffer, 0, header.length)))) is header

  check_version: ->
    @dataview.getUint32(header.length)

  # Binary log file specification can be found here:
  # http://robocupssl.cpe.ku.ac.th/gamelogs
  parse_packet: ->
    # TODO: worry about endianess
    offset = @offset
    timestamp = new Date(dcodeIO.Long.fromBits(@dataview.getUint32(@offset + 4), @dataview.getUint32(@offset)).toNumber() / 1000 / 1000)
    type = @dataview.getUint32(@offset + 8)
    size = @dataview.getUint32(@offset + 12)
    switch type
      when 1
        # TODO: try to identify packet type
        packet = "TODO"
      when 2
        packet = vision_builder.decode(@buffer.slice(@offset + 16, @offset + 16 + size))
      when 3
        try
          packet = refbox_builder.decode(@buffer.slice(@offset + 16, @offset + 16 + size))
        catch e
          console.log(e)
      else
        packet = "UNSUPPORTED"
    @offset += 16 + size
    return {
      timestamp: timestamp
      type: type
      packet: packet
      offset: offset
    }
    # stubs
    @cb = ->
    @done = ->

  all: (cb, done=->) ->
    while @offset < @buffer.byteLength - 1
      packet = @parse_packet()
      # async call
      #setTimeout -> cb(packet)
      # sync call
      cb(packet)
    done.call(this)

  rewind: ->
    @offset = header.length + 4

  pause: ->
    clearTimeout(@_next)
    @playing = false

  start: (cb, done=->) ->
    @cb = cb
    @done = done
    @play()

  stop: ->
    @pause()
    @rewind()

  jump: (offset) ->
    @pause
    setTimeout(=>
      @offset = offset
      @play()
    , 300)

  play: ->
    @playing = true
    @_play(@cb, @done)

  _play: (cb, done) ->
    # XXX: notice we're skipping the first packet
    if @offset < @buffer.byteLength - 1 and @playing
      @previous = @previous || @parse_packet()
      @current = @parse_packet()
      delta = @current.timestamp - @previous.timestamp
      delta = 0 if delta < 0
      @_next = setTimeout (=> @_play(cb)), delta
      @previous = @current
      cb.call(this, @current)
    else
      @done.call(this)
      console.log("stopped")

  cache_offsets: (cb, done=->) ->
    @offsets = []
    until @offset >= @buffer.byteLength
      offset = @offset
      timestamp = new Date(dcodeIO.Long.fromBits(@dataview.getUint32(@offset + 4), @dataview.getUint32(@offset)).toNumber() / 1000 / 1000)
      size = @dataview.getUint32(@offset + 12)
      @offset += 16 + size
      packet =
        timestamp: timestamp
        packet: packet
        offset: offset
      @offsets.push(packet)
      #@last_progress = @progress_step
      #cb(packet, @buffer.byteLength)
    @max_offset = @offset
    @rewind()
    done()

  # cannot use instance after calling this
  destroy: ->
    @stop()
    @buffer = null

# helper for createing throttled get/set functions
# (good to create time/volume-slider, which are used as getter and setter)
class GetSetHandler
  constructor: (@getter, @setter) ->
    @blocked = false

  get: ->
    return if @blocked
    @getter.apply this, arguments

  set: ->
    clearTimeout @throttle_timer
    clearTimeout @blocked_timer
    args = arguments
    @blocked = true
    @throttle_timer = setTimeout(=>
      @setter.apply this, args
      @blocked_timer = setTimeout(=>
        @blocked = false
      , 30)
    , 0)

player_slider = $(".player-slider")
slider_handler = new GetSetHandler(->
    player_slider.val Math.floor(log_parser.offsets.length * log_parser.offset / log_parser.max_offset) if log_parser?
  , ->
    return unless log_parser?
    pos = parseInt player_slider.val()
    offset = log_parser.offsets[pos].offset
    console.log("Jumping to position #{pos} with offset #{offset}")
    log_parser.jump offset
)

player_slider.bind "input", -> slider_handler.set()

playCallback = (p) ->
  console.log("render")

  #player_slider.update(Math.round(100 * p.offset / @max_offset))
  slider_handler.get()

  switch p.type
    when 2
      updateVisionState p.packet, p.timestamp
    when 3
      updateRefereeState p.packet, p.timestamp
    else
      console.log p


$(".play-btn").on "click", (e) ->
  e.preventDefault()
  # Play the file NOW and use the given callback
  if log_parser?
    i = $(this).find("i")
    if log_parser.playing
      console.log("pause")
      log_parser.pause()
      i.addClass("fa-play")
      i.removeClass("fa-pause")
    else
      console.log("play")
      log_parser.play()
      i.removeClass("fa-play")
      i.addClass("fa-pause")

autoplay = true
log_reader = new FileReader()
log_parser = null

_parse_bar = $(".file-progress .parse-progress")
cacheOffsetCallback = (packet, byteLength) ->
  progress = 100 * packet.offset / byteLength
  _parse_bar.attr("style", "width: #{progress}%;")

$(".file-btn").on "click", (e) ->
  e.preventDefault()
  $("#file-input").trigger("click")

load_file = (file) ->
  # clear stuff related to the current logplay
  if log_parser
    log_parser.destroy()
  # TODO: warn user about the error
  # TODO: allow multi file select with a drop box to pos-choose the file
  # XXX: this is being done here in order to allow better visual feedback
  #      about the decompression progress, as opposed to bloat the LogParser
  #      class with gui stuff
  try
    log_parser = new LogParser(file)
  catch e
    # it didn't work, let's try gunzipping
    try
      unzip = new Zlib.Gunzip(new Uint8Array(file))
      log_parser = new LogParser(unzip.decompress().buffer)
    catch
      # that didn't work either, what about unzipping?
      zip = new JSZip(file)
      # XXX: getting the first file that ends with .log
      log_parser = new LogParser(zip.file(/.*\.log$/)[0].asArrayBuffer())

  # DEBUG:
  window.log_parser = log_parser

  console.log("caching offsets...")
  $(".file-progress .progress-desc").text("Caching binary positions...")
  t1 = new Date()

  # async call to allow drawing to occur
  setTimeout ->
    log_parser.cache_offsets cacheOffsetCallback, ->
      t2 = new Date()
      console.log("cached #{log_parser.offsets.length} offsets in #{t2 - t1}ms")

      # show the button when we're ready to play
      $(".file-progress").hide()
      $(".file-progress .load-progress").attr("style", "width: 0%;")
      $(".player-slider").show()
      $(".player-slider").attr("max", log_parser.offsets.length)
      $(".play-btn").show()

      if autoplay
        #$(".file-progress").hide()
        log_parser.start playCallback
        i = $(".play-btn i")
        i.removeClass("fa-play")
        i.addClass("fa-pause")

$("#file-input").on "change", (e) ->
  # setup actions for when the file is loaded
  log_reader.onloadstart = ->
    $(".file-progress").show()
    $(".file-progress .progress-desc").text("Loading file...")
    $(".player-slider").hide()
    $(".play-btn").hide()

  log_reader.onprogress = (e) ->
    if e.lengthComputable
      percentage = Math.round((e.loaded * 100) / e.total)
      $(".file-progress .load-progress").attr("style", "width: #{percentage}%;")

  log_reader.onload = (e) ->

    # async call to allow visual feedback
    $(".file-progress .load-progress").attr("style", "width: 100%;")

    # DEBUG:
    window.result = @result

    # async call to allow drawing to occur
    setTimeout -> load_file(@result)

  # MUST read as ArrayBuffer, unhide the play/pause button
  log_reader.readAsArrayBuffer(f) for f in e.target.files

# ---------------------------

#socket = io.connect('http://ssl-webclient.roboime.com:8888/')
socket = io.connect('http://127.0.0.1:8888')

socket.on "vision_packet", (packet) ->
  updateVisionState packet

socket.on "refbox_packet", (packet) ->
  updateRefereeState packet

$ ->
  $("[data-toggle='tooltip']").tooltip()
  field = $("#field")[0]
  $(".fullscreen-btn").click ->
    if screenfull.enabled
      screenfull.toggle(field)

$("#console_canvas input").on "keydown", (evt) ->
  if evt.keyCode != 13
      return
  command = this.value
  split = command.split(' ')
  obj = 
    method: ""
    args: []
  if split.length == 0
    return
  obj.cmd = split[0]
  obj.args.push(split[i]) for i in [1..split.length]
  obj.args.splice(obj.args.length - 1, 1)
  $("#cout").append "<div>" + command + "</div>"
  socket.emit "cmd_packet", obj


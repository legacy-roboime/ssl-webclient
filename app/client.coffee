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

$ = require("jquery")
screenfull = require("screenfull")
io = require("socket.io-client")
JSZip = require("jszip")
pako = require("pako")
{Painter} = require("./draw")
{LogPlayer} = require("./logplayer")

# expose jquery so bootstrap doesn't go nuts
window.jQuery = $

painter = new Painter()


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
    player_slider.val Math.floor(log_player.offsets.length * log_player.offset / log_player.max_offset) if log_player?
  , ->
    return unless log_player?
    pos = parseInt player_slider.val()
    offset = log_player.offsets[pos].offset
    console.log("Jumping to position #{pos} with offset #{offset}")
    log_player.jump offset
)

player_slider.bind "input", -> slider_handler.set()

shouldRender = false
playCallback = (p) ->
  #console.log("render")

  #player_slider.update(Math.round(100 * p.offset / @max_offset))
  slider_handler.get()

  switch p.type
    when 2
      painter.updateVision p.packet, p.timestamp
    when 3
      painter.updateReferee p.packet, p.timestamp
    else
      console.log p

  shouldRender = true


$(".play-btn").on "click", (e) ->
  e.preventDefault()
  # Play the file NOW and use the given callback
  if log_player?
    i = $(this).find("i")
    if log_player.playing
      console.log("pause")
      log_player.pause()
      i.addClass("fa-play")
      i.removeClass("fa-pause")
    else
      console.log("play")
      log_player.play()
      i.removeClass("fa-play")
      i.addClass("fa-pause")

autoplay = true
log_reader = new FileReader()
log_player = null

_parse_bar = $(".file-progress .parse-progress")
cacheOffsetCallback = (packet, byteLength) ->
  progress = 100 * packet.offset / byteLength
  _parse_bar.attr("style", "width: #{progress}%;")

$(".file-btn").on "click", (e) ->
  e.preventDefault()
  $("#file-input").trigger("click")

load_file = (file) ->
  # clear stuff related to the current logplay
  if log_player
    log_player.destroy()
  # TODO: warn user about the error
  # TODO: allow multi file select with a drop box to pos-choose the file
  # XXX: this is being done here in order to allow better visual feedback
  #      about the decompression progress, as opposed to bloat the LogPlayer
  #      class with gui stuff
  try
    log_player = new LogPlayer(file)
  catch e1
    # it didn't work, let's try gunzipping
    try
      out = pako.inflate(new Uint8Array(file))
      log_player = new LogPlayer(out)
      #unzip = new zlib.Gunzip(new Uint8Array(file))
      #log_player = new LogPlayer(unzip.decompress().buffer)
    catch e2
      # that didn't work either, what about unzipping?
      try
        zip = new JSZip(file)
        # XXX: getting the first file that ends with .log
        log_player = new LogPlayer(zip.file(/.*\.log$/)[0].asArrayBuffer())
      catch e3
        console.log("could not open log file, one if these is the cause:\n  #{e1}\n  #{e2}\n  #{e3}")

  # DEBUG:
  window.log_player = log_player

  console.log("caching offsets...")
  $(".file-progress .progress-desc").text("Caching binary positions...")
  t1 = new Date()

  # async call to allow drawing to occur
  #setTimeout ->
  requestAnimationFrame ->
    log_player.cache_offsets cacheOffsetCallback, ->
      t2 = new Date()
      console.log("cached #{log_player.offsets.length} offsets in #{t2 - t1}ms")

      # show the button when we're ready to play
      $(".file-progress").hide()
      $(".file-progress .load-progress").attr("style", "width: 0%;")
      $(".player-slider").show()
      $(".player-slider").attr("max", log_player.offsets.length)
      $(".play-btn").show()

      if autoplay
        #$(".file-progress").hide()
        log_player.start playCallback
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
    #setTimeout -> load_file(@result)
    requestAnimationFrame -> load_file(@result)

  # MUST read as ArrayBuffer, unhide the play/pause button
  log_reader.readAsArrayBuffer(f) for f in e.target.files

  window.target = e.target

# ---------------------------

#socket = io.connect('http://ssl-webclient.roboime.com:8888/')
socket = io.connect()

socket.on "vision_packet", (packet) ->
  painter.updateVision packet

socket.on "refbox_packet", (packet) ->
  painter.updateReferee packet

socket.on "cmd_packet", (packet) ->
  span_class = if packet.ok is true then "success" else if packet.ok is false then "fail" else ""
  jscli.print "<span class=\"#{span_class}\">#{packet.out}</span>"

$ ->
  $("[data-toggle='tooltip']").tooltip()

  $(".fullscreen-btn").click ->
    if screenfull.enabled
      screenfull.toggle()

  $(window).keydown (e) ->
    if (e.which == 121 or e.which == 122) and screenfull.enabled
      screenfull.toggle()
      e.preventDefault()

  jscli.eval = (command) ->
    split = command.split(' ')
    socket.emit "cmd_packet",
      cmd: split[0]
      args: split[1..]

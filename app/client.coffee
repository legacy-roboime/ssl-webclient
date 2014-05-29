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
{Painter} = require("./draw")

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
      , 50)
    , 30)

player_slider = $(".player-slider")
slider_handler = new GetSetHandler((val) ->
    player_slider.val val
  , ->
    #return unless log_player?
    pos = parseInt player_slider.val()
    log_worker.postMessage action: "jump", pos: pos
)

player_slider.bind "input", -> slider_handler.set()

shouldRender = false
playCallback = (p, pos) ->
  #console.log("render")

  #player_slider.update(Math.round(100 * p.offset / @max_offset))
  slider_handler.get(pos)

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
  log_worker.postMessage action: "toggleplay"

log_worker = new Worker("logworker.js")
log_worker.onmessage = (e) ->
  switch e.data.status
    when "loaded"
      offsets = e.data.offsets
      # show the button when we're ready to play
      $(".file-progress").hide()
      $(".file-progress .load-progress").attr("style", "width: 0%;")
      $(".player-slider").show()
      $(".player-slider").attr("max", offsets)
      $(".play-btn").show()
    when "started"
      $(".file-progress .load-progress").attr("style", "width: 0%;")
      $(".file-progress").show()
      $(".file-progress .progress-desc").text("Loading file...")
      $(".player-slider").hide()
      $(".play-btn").hide()
    when "progress"
      percentage = e.data.percentage
      $(".file-progress .load-progress").attr("style", "width: #{percentage}%;")
    when "cachestart"
      $(".file-progress .progress-desc").text("Caching binary positions...")
    when "cacheprogress"
      percentage = e.data.percentage
      $(".file-progress .parse-progress").attr("style", "width: #{percentage}%;")
    when "playing"
      #$(".file-progress").hide()
      $(".play-btn i")
        .removeClass("fa-play")
        .addClass("fa-pause")
    when "pausing"
      $(".play-btn i")
        .removeClass("fa-pause")
        .addClass("fa-play")
    when "packet"
      playCallback e.data.packet, e.data.pos

$(".file-btn").on "click", (e) ->
  e.preventDefault()
  $("#file-input").trigger("click")

$("#file-input").on "change", (e) ->
  log_worker.postMessage action: "load", files: e.target.files

# ---------------------------

#socket = io.connect('http://ssl-webclient.roboime.com:8888/')
socket = io.connect()

socket.on "vision_packet", (packet) ->
  painter.updateVision packet

socket.on "refbox_packet", (packet) ->
  painter.updateReferee packet

socket.on "cmd_packet", (packet) ->
  span_class = if packet.ok is true then "success" else if packet.ok is false then "fail" else ""
  if jscli?
    jscli.print "<span class=\"#{span_class}\">#{packet.out}</span>"

$ ->
  $("[data-tooltip]").tooltip()

  $(".fullscreen-btn").click ->
    if screenfull.enabled
      screenfull.toggle()

  $(window).keydown (e) ->
    if (e.which == 121 or e.which == 122) and screenfull.enabled
      screenfull.toggle()
      e.preventDefault()

  if jscli?
    jscli.eval = (command) ->
      split = command.split(' ')
      socket.emit "cmd_packet",
        cmd: split[0]
      args: split[1..]

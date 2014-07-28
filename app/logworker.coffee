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

JSZip = require("jszip")
pako = require("pako")
{LogPlayer} = require("./logplayer")

autoplay = true
log_reader = new FileReader()
log_player = null

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

  console.log("caching offsets...")
  postMessage status: "cachestart"
  t1 = new Date()

  log_player.cache_offsets cacheOffsetCallback, ->
    t2 = new Date()
    console.log("cached #{log_player.offsets.length} offsets in #{t2 - t1}ms")
    postMessage status: "loaded", offsets: log_player.offsets.length

    if autoplay
      #TODO: initialize in a different way, so autoplay can be disabled
      log_player.start (p) ->
        #TODO: should use a the offset list to get this pos instead
        pos = Math.floor(log_player.offsets.length * p.offset / log_player.max_offset)
        postMessage status: "packet", packet: p, pos: pos

      postMessage status: "playing"

cacheOffsetCallback = (packet, byteLength) ->
  percentage = 100 * packet.offset / byteLength
  postMessage status: "cacheprogress", percentage: percentage

# setup actions for when the file is loaded
log_reader.onloadstart = ->
  postMessage status: "started"

log_reader.onprogress = (e) ->
  if e.lengthComputable
    percentage = Math.round((e.loaded * 100) / e.total)
    postMessage status: "progress", percentage: percentage

log_reader.onload = (e) ->
  load_file(@result)

global.onmessage = (e) ->
  switch e.data.action
    when "load"
      files = e.data.files
      # MUST read as ArrayBuffer, unhide the play/pause button
      log_reader.readAsArrayBuffer(f) for f in files
    when "toggleplay"
      if log_player?
        if log_player.playing
          console.log("pause")
          log_player.pause()
          postMessage status: "pausing"
        else
          console.log("play")
          log_player.play()
          postMessage status: "playing"
    when "jump"
      pos = e.data.pos
      console.log "jump to #{pos}"
      log_player.jump pos

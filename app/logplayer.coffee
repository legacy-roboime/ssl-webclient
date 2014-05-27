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

ProtoBuf = require("protobufjs")
Long = require("long")
utils = require("./utils")


class LogPlayer

  header = "SSL_LOG_FILE"
  #XXX: ProtoBuf incorrectly assumes nodejs when loaded on a web worker, this is a hack to circumvent that
  ProtoBuf.Util.IS_NODE = false
  vision_builder = ProtoBuf.loadProtoFile("protos/messages_robocup_ssl_wrapper.proto").build("SSL_WrapperPacket")
  refbox_builder = ProtoBuf.loadProtoFile("protos/referee.proto").build("SSL_Referee")

  constructor: (file, @progress_step=10000) ->

    # try at most to use an ArrayBuffer
    if file.byteLength
      @buffer = file.buffer or file
    else if file.length
      console.warn("Passed a plain array to LogPlayer, you should prefer passing an ArrayBuffer.")
      @buffer = new ArrayBuffer(file.length)
      view = new Uint8Array(@buffer)
      for i in [0...file.length]
        view[i] = file[i]

    @dataview = new DataView(@buffer)

    # SSL_LOG_FILE + version (uint32)
    @offset = header.length + 4
    @last_progress = 0
    # rough approximation if used without caching
    @max_offset = @buffer.byteLength

    unless @check_type()
      throw new Error("Invalid file format")
    unless (ver = @check_version()) == 1
      throw new Error("Unsupported log format version #{ver}")

    #TODO: use this to calculate average lag
    @avgr = utils.sma(100)


  check_type: ->
    decodeURIComponent(String.fromCharCode.apply(null, Array.prototype.slice.apply(new Uint8Array(@buffer, 0, header.length)))) is header

  check_version: ->
    @dataview.getUint32(header.length)

  # Binary log file specification can be found here:
  # http://robocupssl.cpe.ku.ac.th/gamelogs
  parse_packet: ->
    # TODO: worry about endianess
    offset = @offset
    if @new_offset
      offset = @new_offset
      @new_offset = null

    timestamp = new Date(Long.fromBits(@dataview.getUint32(offset + 4), @dataview.getUint32(offset)).toNumber() / 1000 / 1000)
    type = @dataview.getUint32(offset + 8)
    size = @dataview.getUint32(offset + 12)

    switch type
      when 1
        # TODO: try to identify packet type
        packet = "TODO"
      when 2
        packet = vision_builder.decode(@buffer.slice(offset + 16, offset + 16 + size))
      when 3
        try
          packet = refbox_builder.decode(@buffer.slice(offset + 16, offset + 16 + size))
        catch e
          console.log(e)
      else
        packet = "UNSUPPORTED"
    @offset = offset + 16 + size

    timestamp: timestamp
    type: type
    packet: packet
    offset: offset

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
    if @playing
      @playing = false
      clearTimeout(@_next)

  start: (cb, done=->) ->
    @cb = cb
    @done = done
    @play()

  stop: ->
    @pause()
    @rewind()

  jump: (pos) ->
    @new_offset = @offsets[pos].offset
    # send some packages to update even if paused
    # and store on previous to avoid a long timeout
    # due to the big difference in timestamps
    for _ in [0...5]
      @previous = @parse_packet()
      @cb.call(this, @previous)

  play: ->
    unless @playing
      @playing = true
      @_tick()

  _tick: () ->
    t0 = new Date()
    if not @previous? and @playing
      @_next = setTimeout (=> @_tick()), 1 / 120
      @previous = @parse_packet()
      @cb.call(this, @previous)

    else if @offset < @buffer.byteLength - 1 and @playing
      @current = @parse_packet()
      # this block has to run as fast as possible
      delta = Math.max(@current.timestamp - @previous.timestamp - (new Date() - t0), 0)
      @_next = setTimeout (=> @_tick()), delta
      # until here
      @previous = @current
      @cb.call(this, @current)
      if delta > 500
        console.warn "big timeout (#{delta}ms) is this ok?"

    else
      @done.call(this)

  cache_offsets: (cb, done=->) ->
    @offsets = []
    until @offset >= @buffer.byteLength
      offset = @offset
      timestamp = new Date(Long.fromBits(@dataview.getUint32(@offset + 4), @dataview.getUint32(@offset)).toNumber() / 1000 / 1000)
      size = @dataview.getUint32(@offset + 12)
      @offset += 16 + size
      packet =
        timestamp: timestamp
        #packet: packet
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

exports.LogPlayer = LogPlayer

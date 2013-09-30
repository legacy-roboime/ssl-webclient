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

dgram = require("dgram")
protobuf = require("protobufjs")
{tunnel_to, vision, debug, referee} = require("config")

io = require("socket.io-client")
builder = protobuf.protoFromFile("src/protos/messages_robocup_ssl_wrapper.proto")
ref_builder = protobuf.protoFromFile("src/protos/referee.proto")

Wrapper = builder.build("SSL_WrapperPacket")
Referee = ref_builder.build("SSL_Referee")

tunneler = (socket) ->
  vision_client = dgram.createSocket("udp4")

  vision_client.on "listening", ->
    vision_client.setBroadcast true
    vision_client.setMulticastTTL 128
    vision_client.addMembership vision.address
    console.log "Listening for vision on #{vision.address}:#{vision.port} ..."

  vision_client.on "message", (message, remote) ->
    wrapper = Wrapper.decode(message)
    if debug
      console.log "received message from #{remote.address}:"
      console.log wrapper
    socket.emit "ssl_packet", wrapper

  vision_client.bind(vision.port)

  referee_client = dgram.createSocket("udp4")

  referee_client.on "listening", ->
    referee_client.setBroadcast true
    referee_client.setMulticastTTL 128
    referee_client.addMembership referee.address
    console.log "Listening for referee on #{referee.address}:#{referee.port} ..."

  referee_client.on "message", (message, remote) ->
    wrapper = Referee.decode(message)
    if debug
      console.log "received message from #{remote.address}:"
      console.log wrapper
    socket.emit "ssl_refbox_packet", wrapper

  referee_client.bind(referee.port)

module.exports = tunneler

if module is require.main
  # connect to the server to feed it
  tunneler io.connect("#{tunnel_to.proto}://#{tunnel_to.address}/", port: tunnel_to.port)

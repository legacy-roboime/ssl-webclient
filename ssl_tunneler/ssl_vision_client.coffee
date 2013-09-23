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
{http, ssl} = require("config")

#var io = require('socket.io');
io = require("socket.io-client")
builder = protobuf.protoFromFile("ssl_tunneler/protos/messages_robocup_ssl_wrapper.proto")
Wrapper = builder.build("SSL_WrapperPacket")
socket = io.connect("http://#{http.address}/", port: http.port)
client = dgram.createSocket("udp4")

#client.on "listening", ->
#  address = client.address()
#  client.setBroadcast true
#  client.setMulticastTTL 128
#  client.addMembership ssl.address
#  console.log "Listening #{ssl.address}:#{ssl.port}..."

#client.bind ssl.port, "localhost", ->
client.bind ssl.port, "127.0.0.1", ->
  address = client.address()
  client.setBroadcast true
  client.setMulticastTTL 128
  client.addMembership ssl.address, "127.0.0.1"
  console.log "Listening #{ssl.address}:#{ssl.port}..."

client.on "message", (message, remote) ->
  wrapper = Wrapper.decode(message)
  console.log wrapper
  socket.emit "ssl_packet", wrapper

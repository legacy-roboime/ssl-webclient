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

express = require("express")
socketio = require("socket.io")
{join} = require("path")
config = require("config")
{http, debug} = config

app = express()
app.use express.static(join(__dirname, "..", "public"))

port = process.env.PORT || http.port
addr = http.address
io = socketio.listen(app.listen(port, addr))
io.set "log level", 1

# this is so the server is also a local vision listener
if config.self_tunnel
  tunneler = require("./tunneler")
  tunneler io.sockets

io.sockets.on "connection", (socket) ->

  # Right now, we only have one game per instance, so all
  # connected sockets get to see it.

  # TODO: Implement separation of sockets per game
  socket.on "ssl_packet", (packet) ->
    if debug
      console.log packet

    # Forward packet to all the client sockets.
    io.sockets.emit "ssl_packet", packet

  socket.on "ssl_refbox_packet", (packet) ->
    if debug
      console.log packet

    # Forward packet to all the client sockets.
    io.sockets.emit "ssl_refbox_packet", packet

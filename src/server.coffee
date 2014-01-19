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

zmq = require("zmq")

{join} = require("path")
config = require("config")
{http, debug, zmq_conf} = config

zmq_subscriber = zmq.socket("pull");
zmq_publisher = zmq.socket("push");
zmq_publisher.bind "tcp://" + zmq_conf.address + ":" + zmq_conf.push_port
zmq_subscriber.bind "tcp://" + zmq_conf.address + ":" + zmq_conf.pull_port
console.log "publishing to tcp://" + zmq_conf.address + ":" + zmq_conf.push_port
console.log "subscribing to tcp://" + zmq_conf.address + ":" + zmq_conf.pull_port

app = express()
app.get '/*', (req, res, next) ->
  res.setHeader 'Access-Control-Allow-Origin', '*'
  next()

app.use express.static(join(__dirname, "..", "public"))

port = process.env.PORT || http.port
console.log "HTTP server listening on port " + port
addr = http.address
io = socketio.listen(app.listen(port, addr))
io.set "log level", 1
if process.env.LONGPOLLING is "true"
  console.log "using long polling"
  io.set "transports", ["xhr-polling"]
  io.set "polling duration", 10

# this is so the server is also a local vision listener... for now
console.log "Self tunneling activated"
tunneler = require("./tunneler")
tunneler io.sockets

io.sockets.on "connection", (socket) ->

  # Right now, we only have one game per instance, so all
  # connected sockets get to see it.

  # TODO: Implement separation of sockets per game
  socket.on "vision_packet", (packet) ->
    if debug
      console.log packet

    # Forward packet to all the client sockets.
    io.sockets.emit "vision_packet", packet

  socket.on "refbox_packet", (packet) ->
    if debug
      console.log packet

    # Forward packet to all the client sockets.
    io.sockets.emit "refbox_packet", packet

  socket.on "cmd_packet", (packet) ->
    if debug
      console.log packet

    # Forward packet to zmq
    zmq_publisher.send(packet)

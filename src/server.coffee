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
{http, debug} = require("config")

app = express()
app.use express.static(join(__dirname, "..", "public"))
app.set "views", join(__dirname, "..", "app")
app.set "view engine", "jade"
app.engine "jade", require("jade").__express

app.get "/", (request, response) ->
  response.render "list_ongoing.jade"

app.get "/game/:id", (request, response) ->
  response.render "canvas.jade",
    game_id: request.params.id

io = socketio.listen(app.listen(http.port, http.address))
io.set "log level", 1

io.sockets.on "connection", (socket) ->

  # Right now, we only have one game per instance, so all
  # connected sockets get to see it.

  # TODO: Implement separation of sockets per game
  socket.on "ssl_packet", (packet) ->
    if debug
      console.log packet

    # Forward packet to all the client sockets.
    io.sockets.emit "ssl_packet", packet

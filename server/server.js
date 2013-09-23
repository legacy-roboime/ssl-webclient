/**
 * Copyright (C) 2013 RoboIME
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 */

var express = require("express");
var app = express();
var url = require('url');

app.use(express.static(__dirname + '/public'));
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.engine('jade', require('jade').__express);

app.get(
    '/',
    function(request, response) {
        response.render('list_ongoing.jade');
    }
);

app.get(
    '/view_game', 
    function(request, response) {
        var query = url.parse(request.url, true).query;
        response.render('canvas.jade', {game_id: query.id});
    }
);

var io = require('socket.io').listen(app.listen(80));

io.sockets.on(
    'connection', 
    function(socket) {
        socket.on(
            'ssl_packet',
            // Right now, we only have one game per instance, so all 
            // connected sockets get to see it.

            // TODO: Implement separation of sockets per game
            function(packet) {
                console.log(packet);
                // Forward packet to all the client sockets.
                io.sockets.emit('ssl_packet', packet);
            }
        );
    }
);


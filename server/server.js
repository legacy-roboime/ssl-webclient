var express = require("express");
var app = express();
var url = require('url');

app.use(express.static(__dirname + 'public'));
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
        socket.emit('conn_ack', {message: 'acknowledged'});
        socket.on(
            'new_game', 
            function(game_name) {

            }
        
        )
        socket.on(
            'ssl_packet', 
            function(packet) {
                // Forward packet to all the client sockets.
                io.sockets.emit('ssl_packet', packet);
            }
        );
    }
);


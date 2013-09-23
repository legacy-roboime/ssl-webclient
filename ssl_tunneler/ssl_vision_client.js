var dgram = require('dgram');
var protobuf = require('protobufjs');
//var io = require('socket.io');
var io = require('socket.io-client');

var builder = protobuf.protoFromFile('ssl_tunneler/protos/messages_robocup_ssl_wrapper.proto')
var Wrapper = builder.build('SSL_WrapperPacket');

var socket = io.connect('http://localhost/', { port: 80 });
var client = dgram.createSocket('udp4');

client.on(
    'listening', 
    function() {
        var address = client.address();
        console.log('Listening...');
        client.setBroadcast(true);
        client.setMulticastTTL(128);
        client.addMembership('224.5.23.2', 'localhost')
    }
);

client.on(
    'message',
    function(message, remote) {
        var wrapper = Wrapper.decode(message);
        console.log(wrapper);
        socket.emit('ssl_packet', wrapper);
    }
);

client.bind(10002, 'localhost');

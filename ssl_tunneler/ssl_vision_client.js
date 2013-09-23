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

client.bind(11002, 'localhost');

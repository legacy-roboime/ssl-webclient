ssl-vision-webclient
====================

Connects to an SSL vision multicast socket and pushes this information to a server with websockets.

Getting Started
---------------

### Requirements

- [node.js](http://nodejs.org/)
- grunt-cli: `npm install -g grunt-cli`
- coffee-script: `npm install -g coffee-script`
- other deps: `npm install`

### Usage

    grunt run

If you opt not to run the server a tunneler, the following will be needed.

    grunt tunneler

You can configure your local preferences by creating a `config/development.yaml`, (or `.json`, `.js`) and
adding what would otherwise be altered on `config/default.yaml`.

License
-------

This software is licensed under AGPL, read the [LICENSE file](LICENSE) for more information.

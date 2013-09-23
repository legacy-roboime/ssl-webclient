ssl-vision-webclient
====================

ssl-vision-webclient is a multi-user supporting web-based application for streaming and viewing Small Size League robot football games written using node.js.

Getting Started
---------------

### Requirements

- [node.js](http://nodejs.org/)
- grunt-cli: `npm install -g grunt-cli`
- coffee-script: `npm install -g coffee-script`
- other deps: `npm install`

### Usage

    grunt run

Unless you opt to run the server as the vision/referee client, the following will also be needed. Remember that the tunneler (or, as it may be, the server) must be in the same network as the ssl-vision and ssl-refbox boxes.

    grunt tunneler

You can configure your local preferences by creating a `config/development.yaml`, (or `.json`, `.js`) and
adding what would otherwise be altered on `config/default.yaml`.

License
-------

This software is licensed under AGPL, read the [LICENSE file](LICENSE) for more information.

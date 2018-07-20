ssl-webclient-internal
======================

ssl-webclient-internal is a multi-user supporting web-based application for controlling pyroboime (http://github.com/roboime/pyroboime) from a local browser.

Getting Started
---------------

### Docker
The easiest way to run this client is to use a docker.
To build the docker image do the following:
```bash
docker build -t ssl-webclient .
```
To run that docker image and launch a server on `127.0.0.1:8888`, do the following:
```bash
docker run -p 8888:8888 -it ssl-webclient
```

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

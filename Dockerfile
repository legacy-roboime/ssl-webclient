FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

RUN sudo apt-get update --yes
RUN sudo apt-get install --assume-yes git nodejs npm  libzmq3-dbg libzmq3-dev libzmq3

WORKDIR /app
ADD . /app
#RUN git clone https://github.com/legacy-roboime/ssl-webclient.git
#WORKDIR ssl-webclient

# It's been too long and the ssl domain has change
RUN npm config set strict-ssl false

# I don't why but there `node` does not point to `nodejs`
RUN ln -s /usr/bin/nodejs /usr/bin/node 

RUN npm install -g coffee-script
RUN npm install -g grunt-cli

RUN npm install

RUN npm install bower zmq
RUN ./node_modules/bower/bin/bower --allow-root install

EXPOSE 8888

CMD grunt run 

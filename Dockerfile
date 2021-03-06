FROM ubuntu:14.04
MAINTAINER Avner Cohen "israbirding@gmail.com"

# make sure the package repository is up to date
RUN apt-get update && apt-get upgrade -y && \
    apt-get install gnupg && wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - && echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse' | tee /etc/apt/sources.list.d/mongodb-org-4.4.list && \
    apt-get update && apt-get install -y mongodb-org build-essential git curl zip inotify-tools python

ENV NODE_VERSION 8.14.0
RUN curl https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz -o /tmp/node.tar.gz && ( cd /usr/local && tar xvzf /tmp/node.tar.gz --strip-components=1 ; )

# INSTALL YARN
RUN npm install -g yarn

ENV FONTELLO_VERSION 8.0.0
RUN git clone --depth 1 -b "${FONTELLO_VERSION}" git://github.com/fontello/fontello.git fontello && ( cd fontello && git submodule update --init && yarn install ) && \
    mkdir -p /data/db

ADD ./application.yml /fontello/config/application.yml

WORKDIR /fontello

RUN apt-get install -y wget automake libtool && yes | ./support/ttfautohint-ubuntu-12.04.sh && \
    apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY ./entrypoint.js /usr/local/bin/entrypoint.js

EXPOSE 3000
CMD [ "node", "/usr/local/bin/entrypoint.js" ]

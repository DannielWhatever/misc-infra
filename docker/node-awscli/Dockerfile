FROM node:16-buster-slim

MAINTAINER Daniel Gutiérrez <dannielgutierrez90@gmail.com>

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        build-essential g++ python2.7 python2.7-dev unzip curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp \
    && cd /tmp \
    && curl -k -O https://bootstrap.pypa.io/pip/2.7/get-pip.py \
    &&  python2.7 get-pip.py \
    && rm -f /tmp/get-pip.py

RUN pip install awscli

###########################################################
##
## Copyright (c) 2018 Dr. Dennis Krannich
## 
## Created:         2018-12-08
## Last updated:    2018-12-19
## 
###########################################################
##
## Alexa-FHEM
##
###########################################################

FROM alpine:latest

MAINTAINER Dr. Dennis Krannich

ENV TZ 'Europe/Berlin'

RUN apk add --no-cache --update \
    tzdata \
    bash \
    ca-certificates \
    wget \
    nano \
    npm \
    nodejs \ 
    curl 


## Clean up APT when done
RUN \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

## Customizing console
RUN \
    echo "alias ll='ls -lah --color=auto'" >> /root/.bashrc

## Setting timezone
RUN \
    cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Brussels" > /etc/timezone
    

## Installing alexa-fhem

RUN npm cache clean -f && \
    npm install -g n &&\
    n stable

ADD ./core/alexa-fhem-0.4.4.tgz /

RUN \
    mv package alexa-fhem && cd alexa-fhem &&\
	npm install &&\
	npm audit fix
	

## Linking config files

RUN mkdir ~/.alexa

COPY ./config/ /alexa-fhem/

RUN ln -s /alexa-fhem/config.json ~/.alexa/config.json

COPY ./core/start.sh /alexa-fhem/


## Starting container

WORKDIR /alexa-fhem/

EXPOSE 3000

CMD ["bash","/alexa-fhem/start.sh"]

# EOF
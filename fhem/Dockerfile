###########################################################
##
## Copyright (c) 2018 Dr. Dennis Krannich
## 
## Created:         2018-12-08
## Last updated:    2018-12-19
## 
###########################################################
##
## FHEM 5.8
##
## with:
## + ImageMagick (for status screen on Kindle)
## + libXML (for reading XML files)
## + libCrypt-Rijndael (for Keymatic)
##
## without:
## - mysql db support 
##
###########################################################

FROM alpine:latest

MAINTAINER Dr. Dennis Krannich <blogger@krannich.de>


ENV \
    TERM=xterm\
    TZ=Europe/Berlin


RUN apk add --no-cache --update \
    tzdata \
    bash \
    sudo \
    sed \
    ca-certificates \
    wget \
    nano \
    perl \
    perl-socket \
    perl-switch \
    perl-sys-hostname-long \
    perl-json \
    perl-io-socket-ssl \
    perl-crypt-openssl-rsa \
    perl-crypt-openssl-dsa \
    perl-xml-simple \
    perl-socket \
    perl-crypt-rijndael \
    perl-lwp-protocol-https \
    perl-device-serialport \
    perl-net-telnet \
    perl-dbi \
    perl-dbd-mysql \
    busybox-extras \
    imagemagick \
    ttf-dejavu


## Cleaning up APK
RUN \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*


## Customizing console
RUN \
    echo "alias ll='ls -lah --color=auto'" >> /root/.bashrc


## Setting timezone
RUN \
    cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Brussels" > /etc/timezone
    

## Installing fonts for Kindle status screen 

COPY ./fonts/meteocons/ /usr/share/fonts/truetype/

RUN chmod -R a+r /usr/share/fonts/*

RUN fc-cache -f -v


# Installing backup script for local backup

COPY ./core/backup.sh /opt/fhem/backup.sh

RUN chmod +x /opt/fhem/backup.sh


## Starting container

WORKDIR "/opt/fhem"

EXPOSE 8083 7072

ENTRYPOINT ["/opt/fhem/start-fhem.sh"]

## EOF
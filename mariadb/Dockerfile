###########################################################
##
## Copyright (c) 2018 Dr. Dennis Krannich
## 
## Created:         2019-01-05
## Last updated:    2019-01-06
## 
###########################################################
##
## MariaDB
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
    nano
   
   
## Installing MariaDB and PasswordGenerator 
RUN apk --update --no-cache add \
    mariadb \
    mariadb-client \
    pwgen
      
        
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


## Configuring MariaDB
RUN \
    mkdir -p /etc/mysql/conf.d \
    && { \
        echo '[mysqld]'; \
        echo 'skip-host-cache'; \
        echo 'skip-name-resolve'; \
        echo 'user = mysql'; \
        echo 'datadir = /var/lib/mysql'; \
        echo '!includedir /etc/mysql/conf.d/'; \
    } > /etc/mysql/my.cnf


## Importing initial FHEM database
COPY ./files/docker-entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh


ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306

CMD ["mysqld"]

# EOF
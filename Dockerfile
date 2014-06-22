FROM        ubuntu:12.10
MAINTAINER Joshua Ashby "joshuaashby@joshashby.com"


# RethinkDB
RUN         source /etc/lsb-release && \
              echo "deb http://download.rethinkdb.com/apt $DISTRIB_CODENAME main" | sudo tee /etc/apt/sources.list.d/rethinkdb.list
RUN         wget -O- http://download.rethinkdb.com/apt/pubkey.gpg | sudo apt-key add -
RUN         apt-get update
RUN         apt-get -y install rethinkdb

EXPOSE      8080   # web UI
EXPOSE      28015  # process
EXPOSE      29015  # cluster


# Redis
RUN         apt-get -y install redis-server
EXPOSE      6379


# nginx
RUN         apt-get -y install redis-server
RUN         mkdir /etc/nginx/transientbug
ADD         ssl-unified.crt /etc/nginx/transientbug/ssl-unified.crt
ADD         private.key /etc/nginx/transientbug/private.key
ADD         nginx /etc/nginx/sites-available/transientbug
RUN         ln -s /etc/nginx/sites-avalabled/transientbug /etc/nginx/sites-enabled/


# Transientbug
RUN         apt-get -y install nodejs npm git-core python
RUN         easy_install pip

ADD         docker_provision.sh docker_provision.sh
RUN         chmod +x docker_provision.sh
RUN         ./docker_provision.sh

EXPOSE      80
EXPOSE      433

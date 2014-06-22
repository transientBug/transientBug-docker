FROM        ubuntu:12.10
MAINTAINER Joshua Ashby "joshuaashby@joshashby.com"

# update things and install nice things
RUN         apt-get update
RUN         apt-get -y install wget g++ curl libssl-dev apache2-utils git-core python python-pip python-dev libffi-dev

RUN         mkdir /root/.ssh
RUN         touch /root/.ssh/known_hosts
RUN         ssh-keyscan github.com >> /root/.ssh/known_hosts

# RethinkDB
RUN         echo "deb http://download.rethinkdb.com/apt precise main" | tee /etc/apt/sources.list.d/rethinkdb.list
RUN         wget -O- http://download.rethinkdb.com/apt/pubkey.gpg | apt-key add -
RUN         apt-get update
RUN         apt-get -y install rethinkdb

# web UI process cluster
EXPOSE 8080 28015 29015


# Redis
RUN         apt-get -y install redis-server

EXPOSE      6379


# nginx
RUN         apt-get -y install nginx

EXPOSE      80
EXPOSE      443


# Node.js
RUN         git clone git://github.com/joyent/node.git
WORKDIR     /node
RUN         ./configure;
RUN         make
RUN         make install


# Transientbug nginx
RUN         mkdir /etc/nginx/transientbug
ADD         transientbug/ /etc/nginx/transientbug
ADD         nginx /etc/nginx/sites-available/transientbug
RUN         ln -s /etc/nginx/sites-avalabled/transientbug /etc/nginx/sites-enabled/


# Transientbug site and assets
WORKDIR     /
RUN         git clone git://github.com/transientBug/transientBug.git@dev
WORKDIR     /transientBug
RUN         npm install

RUN         pip install -r requirements.txt
RUN         ln -s /transientBug/app/config/live/config_dev.yaml /transientBug/app/config/config.yaml
RUN         ln -s /transientBug/app/config/live/initial_dev.yaml /transientBug/app/config/initial.yaml

RUN         ./node_modules/grunt-cli/bin/grunt
RUN         cp -r interface/build/* /var/www/

#ADD         docker_provision.sh docker_provision.sh
#RUN         chmod +x docker_provision.sh
#RUN         ./docker_provision.sh

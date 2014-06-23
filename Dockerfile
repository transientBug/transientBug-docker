FROM        ubuntu
MAINTAINER Joshua Ashby "joshuaashby@joshashby.com"

# update things and install nice things
RUN         apt-get update
RUN         apt-get -y install wget g++ curl libssl-dev apache2-utils git-core python python-pip python-dev libffi-dev

#RUN         mkdir /root/.ssh
#RUN         touch /root/.ssh/known_hosts
#RUN         ssh-keyscan github.com >> /root/.ssh/known_hosts

# RethinkDB
RUN         echo "deb http://download.rethinkdb.com/apt trusty main" | tee /etc/apt/sources.list.d/rethinkdb.list
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


# build node.js because ubuntu can't keep things updated
RUN         git clone git://github.com/joyent/node.git
WORKDIR     /node
RUN         ./configure;
RUN         make
RUN         make install


# Start all the services
# add the rethink config
ADD         rethinkdb.conf /etx/rethinkdb/instances.d/instance1.conf

# Transientbug nginx
ADD         transientbug/ /etc/nginx/transientbug
ADD         nginx /etc/nginx/sites-available/transientbug
RUN         ln -s /etc/nginx/sites-avalabled/transientbug /etc/nginx/sites-enabled/

# Start the services we need for transientbug
RUN         service rethinkdb start
RUN         service redis-server start
RUN         service nginx start


# Transientbug site and assets
RUN         mkdir /var/www
RUN         mkdir /var/www/i

RUN         mkdir /transientBug
WORKDIR     /transientBug

RUN         git clone git://github.com/transientBug/transientBug.git /transientBug
RUN         git checkout dev
RUN         npm install
RUN         pip install -r requirements.txt

RUN         ln -s /transientBug/app/config/live/config_live.yaml /transientBug/app/config/config.yaml
RUN         ln -s /transientBug/app/config/live/initial_live.yaml /transientBug/app/config/initial.yaml

RUN         ./node_modules/grunt-cli/bin/grunt
RUN         cp -r interface/build/* /var/www

ADD         /backups /backups
WORKDIR     /backups
RUN         rethinkdb restore db_backup.tar.gz
RUN         tar -xvzf image_backup.tar.gz -C /var/www/i/

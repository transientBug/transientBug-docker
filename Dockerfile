FROM        ubuntu:12.10

# Update and install rethinkdb and redis
RUN         apt-get update
RUN         source /etc/lsb-release && echo "deb http://download.rethinkdb.com/apt $DISTRIB_CODENAME main" | sudo tee /etc/apt/sources.list.d/rethinkdb.list
RUN         wget -O- http://download.rethinkdb.com/apt/pubkey.gpg | sudo apt-key add -
RUN         apt-get update
RUN         apt-get -y install rethinkdb redis-server

# RethinkDB
#   - 8080: web UI
#   - 28015: process
#   - 29015: cluster
EXPOSE      8080
EXPOSE      28015
EXPOSE      29015

# Redis
EXPOSE      6379

# Transientbug
EXPOSE      80

cd /vagrant

echo "deb http://download.rethinkdb.com/apt precise main" | tee /etc/apt/sources.list.d/rethinkdb.list
wget -O- http://download.rethinkdb.com/apt/pubkey.gpg | apt-key add -
apt-get update

# Rethink, redis, nginx, docker and python and git
apt-get -y install wget g++ curl libssl-dev make apache2-utils git-core python python-pip python-dev libffi-dev rethinkdb redis-server nginx vim

# add the rethink config
cp rethinkdb.conf /etc/rethinkdb/instances.d/instance1.conf

# Transientbug nginx
cp -r ssl/ /etc/nginx/transientbug
cp nginx /etc/nginx/sites-available/transientbug

# Link and enable the site, and remove the default that catches everything
ln -s /etc/nginx/sites-available/transientbug /etc/nginx/sites-enabled/transientbug
rm /etc/nginx/sites-enabled/default

# Transientbug static stuff
mkdir /var/www
chown -R vagrant:vagrant /var/www/
sudo -H -u vagrant mkdir /var/www/static


# Add docker
#curl https://get.docker.io/ubuntu/ | sh
#usermod -aG docker vagrant


# build node.js because ubuntu can't keep things updated
git clone git://github.com/joyent/node.git /vagrant/node
cd node
./configure;
make
make install

# and now install the actual site code
cd /transientBug

# Needed modules
npm install
pip install -r requirements.txt --upgrade

# Link configs
sudo -H -u vagrant ln -s /transientBug/app/config/live /transientBug/app/config/current
sudo -H -u vagrant ln -s /transientBug/app/config/live/supervisord.conf /transientBug/app/supervisord.conf

# Build static resources
sudo -H -u vagrant ./node_modules/grunt-cli/bin/grunt
sudo -H -u vagrant cp -r interface/build/* /var/www/static

# make dirs for pid and logs
sudo -H -u vagrant mkdir app/logs
sudo -H -u vagrant mkdir app/pid


# Restore things
cd /vagrant/backups
rethinkdb restore db_backup.tar.gz
sudo -H -u vagrant mkdir tmp
sudo -H -u vagrant tar -xzf static_backup.tar.gz -C tmp/
sudo -H -u vagrant mv tmp/var/www/transientbug/html/{i,scrn} /var/www/
sudo -H -u vagrant rm -rf tmp


# Start the services we need for transientbug
service rethinkdb start
service redis-server start
service nginx start

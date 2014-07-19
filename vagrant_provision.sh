cd /vagrant

echo "deb http://download.rethinkdb.com/apt precise main" | tee /etc/apt/sources.list.d/rethinkdb.list
wget -O- http://download.rethinkdb.com/apt/pubkey.gpg | apt-key add -
apt-get update

# Rethink, redis, nginx, docker and python and git
apt-get -y install wget g++ curl libssl-dev make apache2-utils git-core python python-pip python-dev libffi-dev rethinkdb redis-server nginx vim

curl https://get.docker.io/ubuntu/ | sh
usermod -aG docker vagrant


# build node.js because ubuntu can't keep things updated
git clone git://github.com/joyent/node.git
cd node
./configure;
make
make install


cd /vagrant

# add the rethink config
cp rethinkdb.conf /etc/rethinkdb/instances.d/instance1.conf

# Transientbug nginx
cp -r transientbug/ /etc/nginx/transientbug
cp nginx /etc/nginx/sites-available/transientbug

ln -s /etc/nginx/sites-avalabled/transientbug /etc/nginx/sites-enabled/transientbug
rm /etc/nginx/sites-enabled/default

# Start the services we need for transientbug
service rethinkdb start
service redis-server start
service nginx start


# Transientbug stuff
mkdir /var/www
chown -R vagrant:vagrant /var/www/
sudo -H -u vagrant mkdir /var/www/static

mkdir /transientBug
chown -R vagrant:vagrant /transientBug
sudo -H -u vagrant git clone git://github.com/transientBug/transientBug.git /transientBug

cd /transientbug

sudo -H -u vagrant git checkout dev
sudo -H -u vagrant npm install
sudo -H -u vagrant pip install -r requirements.txt --upgrade

sudo -H -u vagrant ln -s /transientBug/app/config/live/config_live.yaml /transientBug/app/config/config.yaml
sudo -H -u vagrant ln -s /transientBug/app/config/live/initial_live.yaml /transientBug/app/config/initial.yaml

sudo -H -u vagrant ./node_modules/grunt-cli/bin/grunt
sudo -H -u vagrant cp -r interface/build/* /var/www/static

sudo -H -u vagrant mkdir app/logs
sudo -H -u vagrant mkdir app/pid

cd /vagrant/backups
# Restore things
rethinkdb restore db_backup.tar.gz
sudo -H -u vagrant tar -xzf static_backup.tar.gz -C /var/www/

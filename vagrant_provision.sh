cd /vagrant

echo "deb http://download.rethinkdb.com/apt precise main" | tee /etc/apt/sources.list.d/rethinkdb.list
wget -O- http://download.rethinkdb.com/apt/pubkey.gpg | apt-key add -
apt-get update

# Rethink, redis, nginx, docker and python and git
apt-get -y install wget g++ curl libssl-dev make apache2-utils git-core python python-pip python-dev libffi-dev rethinkdb redis-server nginx

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
mkdir /var/www/static
mkdir /var/www/scrn

chown -R vagrant:vagrant /transientBug
chown -R vagrant:vagrant /var/www/

mkdir /transientBug
cd /transientBug

git clone git://github.com/transientBug/transientBug.git /transientBug
git checkout master
npm install
pip install -r requirements.txt

ln -s /transientBug/app/config/live/config_live.yaml /transientBug/app/config/config.yaml
ln -s /transientBug/app/config/live/initial_live.yaml /transientBug/app/config/initial.yaml

./node_modules/grunt-cli/bin/grunt
cp -r interface/build/* /var/www/static

cd /vagrant/backups
# Restore things
rethinkdb restore db_backup.tar.gz
tar -xvzf image_backup.tar.gz -C /var/www/i/
tar -xvzf scrn_backup.tar.gz -C /var/www/scrn/

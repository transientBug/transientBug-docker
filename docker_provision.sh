# Build node from source because ubuntu can't keep anything updated these days
git clone git://github.com/joyent/node.git
cd node
./configure
make
make install

cd ../

# Now fetch the transientbug site, and install all the node and python modules
# needed to support it
git clone git://github.com/transientBug/transientBug.git
git checkout dev
cd transientBug
npm install
pip install -r requirements.txt

# Link the configs
ln -s /transientBug/app/config/live/config_dev.yaml /transientBug/app/config/config.yaml
ln -s /transientBug/app/config/live/initial_dev.yaml /transientBug/app/config/initial.yaml

# Build the static assets and copy them over to the area where nginx serves
# from
./node_modules/grunt-cli/bin/grunt
cp -r interface/build/* /var/www

# And populate the system with old backups
rethinkdb restore backups/db_backup.tar.gz
tar -xfv backups/image_backup.tar.gz -C /var/www/i

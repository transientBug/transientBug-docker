git clone git@github.com:transientBug/transientBug.git
cd transientBug
npm install
pip install -r requirements.txt

ln -s /transientBug/app/config/live/config_dev.yaml /transientBug/app/config/config.yaml
ln -s /transientBug/app/config/live/initial_dev.yaml /transientBug/app/config/initial.yaml

./node_modules/grunt-cli/bin/grunt
cp -r interface/build/* /var/www/

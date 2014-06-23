apt-get update
apt-get install -y curl
curl https://get.docker.io/ubuntu/ | sh
usermod -aG docker vagrant

#cd /vagrant/
#docker build -t josh/transientbug .

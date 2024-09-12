sudo rpm -e cfengine-nova-hub
rpm -qa cfbuild* | sudo xargs rpm -e
sudo rm -rf /var/cfengine
sudo rm -rf /opt/cfengine
pkill -9 httpd

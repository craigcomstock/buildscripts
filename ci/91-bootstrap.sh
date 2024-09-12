sudo systemctl start cf-execd # for some reason the bootstrap in post-install script isn't starting cf-execd
sudo /var/cfengine/bin/cf-agent -IB $(hostname -I | awk '{print $1}') | tee bs.log

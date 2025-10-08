#!/bin/bash
set -ex
. mender-qa/scripts/initialize-build-host.sh
if false; then
  echo "==== rm /tmp/cfengine-pause when you are ready for buildscripts provisioning to start ===="
  touch /tmp/cfengine-pause
  while [ -f /tmp/cfengine-pause ]; do
    echo -n '.'
    sleep 5
  done
fi
rm -rf master.zip
wget https://github.com/craigcomstock/buildscripts/archive/refs/heads/ENT-13247/master.zip
unzip master.zip
mv buildscripts-ENT-13247-master buildscripts
rm master.zip
sudo ./buildscripts/ci/setup-cfengine-build-host.sh

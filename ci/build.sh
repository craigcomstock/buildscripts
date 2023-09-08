#!/usr/bin/env bash
# build cfengine hub package
set -ex
export PROJECT=nova
export NO_CONFIGURE=1
export BUILD_TYPE=DEBUG
export ESCAPETEST=yes
# change EXPLICIT_ROLE to hub or agent as you wish
export EXPLICIT_ROLE=hub
export TEST_MACHINE=chroot

# this script assumes either ssh-agent already running with jenkins_sftp_cache key inserted
# as well as the proper public key added to $HOME/.ssh/known_hosts (see docker-build-package.sh)
if ! ssh-add -L | grep jenkins_sftp_cache; then
  set +x # hide secrets
  eval $(ssh-agent -s)
  if [ -z "$SECRET" ]; then
    echo "Need sftp cache ssh secret key. Provide with SECRET env variable"
    exit 1
  else
    echo "$SECRET" | ssh-add -
  fi
  ssh-add -l
  set -x # stop hiding secrets
fi

time ./buildscripts/build-scripts/build-environment-check
time ./buildscripts/build-scripts/install-dependencies
time ./buildscripts/build-scripts/configure # 3 minutes locally
time ./buildscripts/build-scripts/generate-source-tarballs # 1m49
time ./buildscripts/build-scripts/compile
time ./buildscripts/ci/clean-packages.sh || true
time sudo rm -rf /var/cfengine
time sudo rm -rf /opt/cfengine
time ./buildscripts/build-scripts/install-dependencies
time ./buildscripts/build-scripts/package
sudo mkdir -p packages
sudo cp cfengine-nova-hub/*.deb packages/ || true
sudo cp cfengine-nova-hub/*.rpm packages/ || true

# todo maybe save the cache cp -R ~/.cache buildscripts/ci/cache

# clean up
time sudo apt remove -y 'cfbuild*' || true
time sudo apt remove -y 'cfengine-*' || true
time sudo rm -rf /var/cfengine
time sudo rm -rf /opt/cfengine

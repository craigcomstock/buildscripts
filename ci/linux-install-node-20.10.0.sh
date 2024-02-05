#!/usr/bin/env bash
set -ex
cd /opt
curl -k -O https://unofficial-builds.nodejs.org/download/release/v20.10.0/node-v20.10.0-linux-x64-glibc-217.tar.xz
echo "dcfc5dfcdea4d0883bb35a4f2e09bc4745b6e689d88f4ad09d9ccc252024049b  node-v20.10.0-linux-x64-glibc-217.tar.xz" > node-v20.10.0-linux-x64-glibc-217.tar.xz.sha256
sha256sum --check node-v20.10.0-linux-x64-glibc-217.tar.xz.sha256
sudo tar xf node-v20.10.0-linux-x64-glibc-217.tar.xz
sudo tee /etc/profile.d/nodejs.sh << EOF
export NODE_HOME=/opt/node-v20.10.0-linux-x64-glibc-217
export PATH=\$PATH:\$NODE_HOME/bin
EOF
sudo update-alternatives --install /usr/bin/node node /opt/node-v20.10.0-linux-x64-glibc-217/bin/node 1
sudo update-alternatives --install /usr/bin/npm npm /opt/node-v20.10.0-linux-x64-glibc-217/bin/npm 1
sudo update-alternatives --install /usr/bin/npx npx /opt/node-v20.10.0-linux-x64-glibc-217/bin/npx 1
sudo update-alternatives --install /usr/bin/corepack corepack /opt/node-v20.10.0-linux-x64-glibc-217/bin/corepack 1
cd -

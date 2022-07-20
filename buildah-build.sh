#!/usr/bin/env bash
set -e
set -x
# TODO parameterize this so we can just
# buildah from whatever(ubuntu, debian, rhel, centos, alpine, freebsd)
# and have the rest of the business "just work"
PLATFORM=x86_64_linux_ubuntu_20
# BASE_IMAGE is the operating system + build dependency packages installed
# TODO refresh this periodically with apt-get update apt-get upgrade apt-get clean apt-get autoclean apt-get autoremove
BASE_IMAGE="builder:$PLATFORM-base"

NTECH_ROOT=/northern.tech

BUILDER_NAME="ubuntu-builder"
buildah rm "$BUILDER_NAME"

if ! buildah images --quiet "$BASE_IMAGE"; then
  tmp=$(buildah from ubuntu)
  # TODO make more different scripts or even policy to install deps on various platforms
  buildah copy $tmp deps-debian.sh
  time buildah run $tmp -- bash -x deps-debian.sh
  time buildah commit $tmp $BASE_IMAGE
  buildah rm $tmp
fi

builder=$(buildah --name "$BUILDER_NAME" from "$BASE_IMAGE")
# TODO change name of this script and add if/elses for enterprise agent and enterprise hub
time buildah copy $builder $NTECH_ROOT/core /cfe/core
time buildah copy $builder $NTECH_ROOT/buildscripts /cfe/buildscripts
time buildah copy $builder $NTECH_ROOT/masterfiles /cfe/masterfiles
cat env-community-agent.sh | buildah run $builder -- tee -a /root/.bashrc
time buildah run --workingdir /cfe $builder -- bash -i ./buildscripts/build-community-agent.sh


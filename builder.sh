#!/usr/bin/env bash
set -e
set -x
DEPS_IMAGE="builder:build-deps-installed"
BUILD_IMAGE="builder:cfengine-sources-copied"
# TODO conditionally create the other two imgaes
# so caching the dependency updates on the OS and maybe removing the image weekly to cut down on bandwidth

BUILDER_NAME="ubuntu-builder"

buildah rm "$BUILDER_NAME" || true # just in case, delete it first

#builder=$(buildah --name "$BUILDER_NAME" from ubuntu)
#buildah copy $builder build-deps.sh /cfe/
#buildah run $builder -- /bin/bash /cfe/build-deps.sh
#buildah commit $builder builder:build-deps-installed

#git clone --recursive --depth 1 https://github.com/cfengine/core || true
#git clone --depth 1 https://github.com/cfengine/buildscripts || true
#buildah copy $builder core /cfe/core
#buildah copy $builder buildscripts /cfe/buildscripts
#buildah copy $builder build-env.sh /cfe/
#buildah commit $builder builder:cfengine-sources-copied

builder=$(buildah --name "$BUILDER_NAME" from "$BUILD_IMAGE")
echo "builder is $builder"
# run this once... somethow :)
#cat build-env.sh | buildah run $builder -- tee -a /root/.bashrc
buildan run $builder -- bash -i /cfe/buildscripts/build-scripts/autogen
# maybe better to put everything at the root? default root for buildah/container?
buildah run $builder -- bash -i /cfe/buildscripts/build-scripts/clean-buildmachine
buildah run $builder -- bash -i /cfe/buildscripts/build-scripts/build-environment-check
buildah run $builder -- bash -i /cfe/buildscripts/build-scripts/install-dependencies


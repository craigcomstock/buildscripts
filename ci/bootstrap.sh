#!/usr/bin/env bash
set -ex

# find the dir two levels up from here, home of all the repositories
COMPUTED_ROOT="$(readlink -e "$(dirname "$0")/../../")"
# NTECH_ROOT should be the same, but if available use it so user can do their own thing.
NTECH_ROOT=${NTECH_ROOT:-$COMPUTED_ROOT}

#docker run -d debian:stretch --name bootstrap-pr
#export BUILD_TYPE=DEBUG # or RELEASE
#export PROJECT=nova # or not, community if empty?
#NO_CONFIGURE=1 ./buildscripts/build-scripts/autogen
#./buildscripts/build-scripts/bootstrap-tarballs
#rm -rf core masterfiles
#tar -I pigz --exclude-cvs --exclude-backups --exclude="*@tmp" -cf artifacts.tar.gz *

#now that is ready to send along to a host or a container :+1:
docker build -t cfengine/bootstrap -f bootstrap.Dockerfile "$NTECH_ROOT"/buildscripts/ci
docker run -d cfengine/bootstrap --name bootstrap

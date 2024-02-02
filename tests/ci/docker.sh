#!/usr/bin/env bash
  # todo, instead of run with the script here, just run as daemon, run script, run verify script, if all well save as cfengine-build-host-$platform
  # then we could run this once a week or so to catch upgrades and changes, slow the pace down a bit, save the planet :p
set -ex
# find the dir two levels up from here, home of all the repositories
COMPUTED_ROOT="$(readlink -e "$(dirname "$0")/../../")"
# NTECH_ROOT should be the same, but if available use it so user can do their own thing.
NTECH_ROOT=${NTECH_ROOT:-$COMPUTED_ROOT}

function test()
{
  set -x
  platform=$1
  name=cfengine-build-host-test-$platform
  save_name=cfengine-build-host-$platform
  extra_dockerfile_lines=
  if echo $platform | grep redhat; then
    version=$(echo $platform | cut -d- -f2)
    if [ $version -ge 8 ]; then
      cat <<EOF >$platform.Dockerfile
FROM redhat/ubi$version
RUN yum erase -y subscription-manager && yum install -y selinux-policy
CMD sleep infinity
EOF
    else
      cat <<EOF >$platform.Dockerfile
FROM centos:$version
CMD sleep infinity
EOF
    fi
  else
    from=$(echo $platform | sed 's/-/:/')
    cat <<EOF >$platform.Dockerfile
    FROM $from
    CMD sleep infinity
EOF
  fi
  docker stop "$name" || true
  docker rm "$name" || true
  docker rmi "$name" || true
  docker build -f $platform.Dockerfile "$NTECH_ROOT"/buildscripts --tag "$name"
  docker run -d -v "$NTECH_ROOT"/buildscripts:/buildscripts --name "$name" "$name"
  docker exec -i "$name" /buildscripts/ci/setup-cfengine-build-host.sh >"$platform".log 2>&1
  rc=$?
  if [ "$rc" != "0" ]; then
    echo "FAIL: $platform"
    cat $platform.log
  else
    echo "PASS: $platform"
    docker commit "$name" "$save_name"
  fi
}

if [ -z "$1" ]; then
  while IFS= read -r platform
  do
    test $platform
  done < <(awk 'FNR==NR {a[$1];next} !($1 in a)' ../../build-scripts/exotics.txt  ../../build-scripts/labels.txt  | sed 's/PACKAGES.*linux_//' | sed '/mingw/d' | sort -u | sed 's/_/-/')
else
  test $1
fi

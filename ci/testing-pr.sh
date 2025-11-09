#!/usr/bin/env bash
set -ex
source env.sh
function bs
{
  set +e
  ./buildscripts/build-scripts/$1 >$1.log 2>&1
  exit_code=$?
  set +e
  echo "$1: exit code: $exit_code"
  if [ "$exit_code" != 0 ]; then
    grep -i error $1.log
  fi
}
bs clean-buildmachine
bs install-dependencies
exit 0
bs configure
bs compile
bs package
bs test

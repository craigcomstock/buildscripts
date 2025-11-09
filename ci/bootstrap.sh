#!/usr/bin/env bash
# assuming only buildscripts was checked out, build a client and hub package for the current platform
# idempotent, if a step doesn't need to be performed, skip it
# make a mechanism to re-do steps somehow, flag files? rm a flag file
# if other repos are already checked out, use them and leave them alone
set -ex

wget https://gitlab.com/Northern.tech/OpenSource/GODS/-/raw/master/parallel_git_rev_fetch.sh
chmod u+x ./parallel_git_rev_fetch.sh

for repo in core masterfiles enterprise nova mission-portal; do
  echo $repo git@github.com:cfengine/$repo master >> revisions
done

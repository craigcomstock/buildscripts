#!/usr/bin/env bash
set -ex
platform=rhel-10-arm64
name=r10arm
source ~/.venv/bin/activate
function cleanup()
{
  echo cleanup
#  cf-remote destroy $name
}
trap cleanup ERR
# todo cf-remote show | grep $name to skip spawn
if ! cf-remote show | grep $name; then
  set -e
  cf-remote spawn --platform $platform --count 1 --role client --name $name 2>&1 | tee log
fi
# todo: wait for ssh to come up!
while true; do
  set +e
  cf-remote run -H $name hostname
  if [ "$?" = "0" ]; then
    break
  fi
  set -e
done
cf-remote scp -H $name buildhost-init-script.sh 2>&1 | tee -a log
cf-remote scp -H $name buildhost-user-data.sh 2>&1 | tee -a log
cf-remote scp -H $name quick-install*sh | tee -a log
# cf-remote sudo breaks the contract of not changing behavior? aka I want stdout/stderr to just GO by default
cf-remote sudo -H $name ./buildhost-user-data.sh 2>&1 | tee -a log
# init-script is tricky, needs to be run in /root, as root and after that runs ssh is closed down on port 22 and opened on port 222, as well as jenkins user is added at that point
#cf-remote sudo -H $name ./buildhost-init-script.sh 2>&1 | tee -a log

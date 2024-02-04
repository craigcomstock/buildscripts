#!/usr/bin/env bash
set -e

# find the dir two levels up from here, home of all the repositories
COMPUTED_ROOT="$(readlink -e "$(dirname "$0")/../../")"
# NTECH_ROOT should be the same, but if available use it so user can do their own thing.
NTECH_ROOT=${NTECH_ROOT:-$COMPUTED_ROOT}

function get_platforms
{
# get all non exotics
#awk 'FNR==NR {a[$1];next} !($1 in a)' ${NTECH_ROOT}/buildscripts/build-scripts/exotics.txt  ${NTECH_ROOT}/buildscripts/build-scripts/labels.txt  | sed 's/PACKAGES.*linux_//' | sed '/mingw/d' | sort -u | sed 's/_/-/'

# get all linux including exotics
cat "${NTECH_ROOT}/buildscripts/build-scripts/labels.txt" | grep '_linux_' | sed 's/PACKAGES.*linux_//' | sort -u | sed 's/_/-/'
}
function banner
{
  echo "### $@ ###"
}
# latest_ami platform (distribution-version)
function latest_ami
{
  platform=$1
banner get latest ami for platform $1
# platform is like suse-12 suse-15 debian-9 redhat-8 ubuntu-18
#platform=redhat-8
#platform=suse-12
distribution=$(echo $platform | cut -d- -f1)
version=$(echo $platform | cut -d- -f2)
case $distribution in
  suse)
    owner_id=013907871322
    name_pattern="suse-sles-$version*"
    ;;
  redhat)
    owner_id=309956199498
    name_pattern="RHEL-$version*"
    ;;
  debian)
    owner_id=136693071363
    name_pattern="debian-$version*" # e.g. debian-12-amd64-20231013-1532
    ;;
  windows)
    owner_id=801119661308
    name_pattern="Windows_Server-$version*" # e.g. Windows_Server-2022-English-Full-Base-2024.01.16
    ;;
  macos)
    owner_id=634519214787
    name_pattern="amxn-ec2-macos-$version*" # e.g. amzn-ec2-macos-14.2.1-20240117-170221
    ;;
  ubuntu)
    owner_id=099720109477
    name_pattern="ubuntu/images/hvm-ssd/ubuntu-*-$version*" # e.g. ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20231207
    ;;
  *)
    echo "Dont know owner_id for distribution $distribution"
    exit 1
    ;;
esac
ami=$(aws ec2 describe-images --owner $owner_id --filters "Name=name,Values=${name_pattern}" "Name=virtualization-type,Values=hvm" "Name=architecture,Values=x86_64" --query 'sort_by(Images[].{YMD:CreationDate,Name:Name,ImageId:ImageId},&YMD)|reverse(@)' --output json --region us-east-2 | jq .[0].ImageId)
echo $ami
}
function owner_from_ami
{
  echo TODO, for manually finding owner-id and name patterns based on ami
}

#banner bootstrap

#suse15ami=$(aws ec2 describe-images --owner "013907871322" --filters "Name=name,Values=suse-sles-15*" "Name=virtualization-type,Values=hvm" "Name=architecture,Values=x86_64" --query 'sort_by(Images[].{YMD:CreationDate,Name:Name,ImageId:ImageId},&YMD)|reverse(@)' --output json --region us-east-2 | jq .[0].ImageId)
#suse12ami=$(aws ec2 describe-images --owner "013907871322" --filters "Name=name,Values=suse-sles-12*" "Name=virtualization-type,Values=hvm" "Name=architecture,Values=x86_64" --query 'sort_by(Images[].{YMD:CreationDate,Name:Name,ImageId:ImageId},&YMD)|reverse(@)' --output json --region us-east-2 | jq .[0].ImageId)
#./spawn-build-host.sh aws $platform $ami # ami is optional, if not provided, use latest golden image
#./testing-pr.sh $ssh_args # spawn-build-host should return ssh_args, so like ip, username, ssh key, port
#if that's ok, then commit back to this repo as a new golden image, maybe do it in bulk every week?
#host clean, snapshot, make PR to buildscripts to update, maybe in bulk
#if not ok, maybe still snapshot but throw an error so easy to investigate without it cleaned up, we can just pickup where it left off and re-run tests and stuff
# saturday morning is exotics
# sunday morning is update golden images

#suse15 from launcher ami-0e6e78596f3522ace
#suse12 ami-0d78dc4fdb90d28a2
#aws ec2 describe-images --image-id ami-0d78...
#ownerid: 013907871322
#name is             "Name": "suse-sles-15-sp5-v20240129-hvm-ssd-x86_64",
#so I could query name for suse-sles-15.*


if [ -z "$1" ]; then
  while IFS= read -r platform
  do
    latest_ami $platform
  done < <(get_platforms)
else
  echo $1
fi

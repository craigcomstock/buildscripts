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
awk 'BEGIN{FS="_"}/linux/ && !/HUB/{print $5"-"$6"-"$2}' "${NTECH_ROOT}/buildscripts/build-scripts/labels.txt" | sort -u
}
function banner
{
  echo "### $@ ###"
}
# latest_ami platform (distribution-version)
function latest_ami
{
  platform=$1
  region=${2:-us-west-1}
#banner get latest ami for platform $1
# platform is like suse-12 suse-15 debian-9 redhat-8 ubuntu-18
#platform=redhat-8
#platform=suse-12
distribution=$(echo $platform | cut -d- -f1)
version=$(echo $platform | cut -d- -f2)
arch=$(echo $platform | cut -d- -f3)
case $distribution in
  suse)
    owner_id=013907871322
    name_pattern="suse-sles-$version*"
    ;;
  redhat)
    if [ "$version" -le 7 ]; then
#      owner_id=379101102735 # ntdev aka us
      owner_id=304194462000 # ntdev aka us
      name_pattern="centos-$version-x64"
    else
      owner_id=309956199498 # https://access.redhat.com/articles/2962171
      name_pattern="RHEL-$version*"
    fi
    ;;
  debian)
    if [ "$version" = "9" ]; then
     owner_id=379101102735 # aka stretch, https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch
     name_pattern="debian-stretch-hvm-x86_64*"
    else
      owner_id=136693071363 # https://wiki.debian.org/Cloud/AmazonEC2Image/Bullseye
      name_pattern="debian-$version*" # e.g. debian-12-amd64-20231013-1532
    fi
    ;;
  windows)
    owner_id=801119661308 # amazon https://docs.aws.amazon.com/powershell/latest/userguide/pstools-ec2-get-amis.html
    name_pattern="Windows_Server-$version*" # e.g. Windows_Server-2022-English-Full-Base-2024.01.16
    ;;
  macos)
    owner_id=634519214787
    name_pattern="amxn-ec2-macos-$version*" # e.g. amzn-ec2-macos-14.2.1-20240117-170221
    ;;
  ubuntu)
    owner_id=099720109477 # https://canonical-aws.readthedocs-hosted.com/en/latest/aws-how-to/instances/find-ubuntu-images/
    if [ "$version" = "16" ]; then
      name_pattern="ubuntu-pro-server/images/hvm-ssd/ubuntu-xenial-16.04-amd64-pro-server*"
    else
      name_pattern="ubuntu/images/hvm-ssd/ubuntu-*-$version*"
    fi
    ;;
  *)
    echo "Dont know owner_id for distribution $distribution"
    exit 1
    ;;
esac
#echo "Looking for ami from owner $owner_id, name_pattern $name_pattern and architecture $arch"
if [ "$arch" = "x86" ]; then
  architecture="x86_64"
elif [ "$arch" = "arm" ]; then
  architecture="arm64"
else
  echo "unknown architecture $arch"
fi
ami=$(aws ec2 describe-images --owner $owner_id --filters "Name=name,Values=${name_pattern}" "Name=virtualization-type,Values=hvm" "Name=architecture,Values=${architecture}" --query 'sort_by(Images[].{YMD:CreationDate,Name:Name,ImageId:ImageId},&YMD)|reverse(@)' --output json --region $region | jq .[0].ImageId)
#ami=$(aws ec2 describe-images --owner $owner_id --filters "Name=name,Values=${name_pattern}" "Name=virtualization-type,Values=hvm" "Name=architecture,Values=${architecture}" --query 'sort_by(Images[].{YMD:CreationDate,Name:Name,ImageId:ImageId},&YMD)|reverse(@)' --output json --region us-east-2 | jq .[0].ImageId)
echo $ami | sed 's/"//g'
}
function owner_from_ami
{
  echo TODO, for manually finding owner-id and name patterns based on ami
}
function spawn_instance
{
  set -x
  platform=$1
  ami=$(latest_ami $platform)
  key_name=craig
  instance_type=t3a.micro
  security_group_id=sg-0f25f4265e18f45ee
  aws ec2 run-instances --image-id $ami --key-name $key_name --instance-type $instance_type --security-group-ids $security_group_id
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

# main

if [ -z "$1" ]; then
  for region in eu-west-1 us-east-2; do
    echo
    echo "### $region ###"
    echo
    while IFS= read -r platform
    do
       ami=$(latest_ami $platform $region)
       echo "$platform <ami>$ami</ami>"
  #    spawn_instance $platform
      # todo how to know when ready and get connection info?
  #--user-data (string)
  #
  #The user data script to make available to the instance. For more information, see Run commands on your Linux instance at launch and Run commands on your Windows instance at launch . If you are using a command line tool, base64-encoding is performed for you, and you can load the text from a file. Otherwise, you must provide base64-encoded text. User data is limited to 16 KB.
  #
  #so send in what we already send :)
  #instances -> state -> code (0=pending)
    done < <(get_platforms)
  done
else
  spawn_instance $1
fi

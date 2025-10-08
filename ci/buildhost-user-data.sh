#!/bin/bash
set -ex
echo "==== start of jenkins aws userData script ===="
whoami
env
hostname
cat /etc/os-release
echo "==== end of host diagnostics which will end up in /var/log/cloud-init-output.log or similar ===="
export HOME=/root
cd

# copied from buildscripts/ci/distribution-patched.sh
for debian_release in stretch buster; do
  if grep "CODENAME=$debian_release" /etc/os-release; then
    echo "deb http://archive.debian.org/debian-archive/debian $debian_release main" >/etc/apt/sources.list
    echo "deb http://archive.debian.org/debian-archive/debian $debian_release-backports main" >>/etc/apt/sources.list
  fi
done
if [ -f /etc/centos-release ]; then
  # OK, it's CentOS, but let's try to get any info we can from /etc/os-release.
  if grep -q "^VERSION_ID=" /etc/os-release; then
    _version=$( grep "^VERSION_ID=" /etc/os-release | cut -d'=' -f2 - | tr -d '"' | cut -d'.' -f1 )
  else
      # Blech, we had this, but it was busted on centos 7, extracting release instead of 7
      _version=$(cat /etc/centos-release | cut -d' ' -f3 | cut -d. -f1)
  fi
  if [ "$_version" = "6" ] || [ "$_version" = "7" ]; then
    sed -i 's/mirror.centos.org/vault.centos.org/;/^mirrorlist/d;s/^#baseurl/baseurl/' /etc/yum.repos.d/CentOS-Base.repo
  fi
fi
if command -v yum; then
  yum -e 0 -d 0 -y update
  yum -e 0 -d 0 -y install unzip rsync wget
fi
if command -v apt; then
  DEBIAN_FRONTEND=noninteractive apt -yqq update
  DEBIAN_FRONTEND=noninteractive apt -yqq upgrade
  DEBIAN_FRONTEND=noninteractive apt install -yqq unzip rsync wget
fi
if command -v zypper; then
  source /etc/os-release
  if [ "$ID" != "sles" ]; then
    rpm --import https://download.opensuse.org/distribution/leap/$VERSION_ID/repo/oss/repodata/repomd.xml.key
    zypper ar -cfp 90 https://download.opensuse.org/distribution/leap/$VERSION_ID/repo/oss/ oss
    for repo in oss sle backports; do
      rpm --import https://download.opensuse.org/update/leap/$VERSION_ID/$repo/repodata/repomd.xml.key
      zypper ar -cfp 70 https://download.opensuse.org/update/leap/$VERSION_ID/$repo/ update-$repo
    done
    zypper -qn ref
    zypper lr  # diagnostic to see what repos are enabled
  fi
  zypper -qn update
  zypper -qn rm libsnmp15
  zypper -qn install unzip rsync wget
  groupadd jenkins || true
  useradd -m -u 1010 -g jenkins jenkins || true
fi

# Add 512MB swap space, java needs it, and jenkins stops complaining.
rm -f master.zip
wget https://github.com/mendersoftware/mender-qa/archive/refs/heads/master.zip
unzip master.zip
mv mender-qa-master mender-qa
rm master.zip
sudo mender-qa/scripts/create_swap_file.sh 512
. mender-qa/scripts/initialize-user-data.sh

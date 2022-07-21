apt update -y
apt upgrade -y
apt install -y git autoconf automake m4 make bison flex binutils libtool gcc g++ libc-dev libpam0g-dev python3 psmisc libtokyocabinet-dev libssl-dev libpcre3-dev default-jre-headless build-essential fakeroot ntp dpkg-dev debhelper pkg-config nfs-common sudo apt-utils wget libncurses5 rsync libexpat1-dev libexpat1 curl
apt purge -y emacs emacs24 libltdl-dev libltdl7
apt install -y procps # provides `ps` for running tests

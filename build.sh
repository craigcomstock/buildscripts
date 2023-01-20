echo "RUN AS ROOT!"
set -e
set -x
#yum whatprovides fuser
sudo yum install -y psmisc
# yum whatprovides patch
sudo yum install -y patch
#Autodetected agent role based on missing Jenkins label and OS.
#ERROR Found unwanted package: libtool-ltdl
sudo yum erase -y libtool-ltdl
#ERROR Missing system package: gcc-c++
sudo yum install -y gcc-c++
#ERROR Missing system package: ncurses-devel
sudo yum install -y ncurses-devel
#ERROR Missing system package: rpm-build
sudo yum install -y rpm-build
#ERROR Missing system package: pam-devel
sudo yum install -y pam-devel
#ERROR Missing system package: wget
sudo yum install -y wget
#. ./mender-qa/scripts/initialize-build-host.sh
export BUILD_TYPE=DEBUG
export ESCAPETEST=yes
export TEST_MACHINE=chroot
export PROJECT=community
export EXPLICIT_ROLE=
#. compile-options
#./buildscripts/build-scripts/autogen
sh -x ./buildscripts/build-scripts/clean-buildmachine
sh -x ./buildscripts/build-scripts/build-environment-check
#+ pkg-install-rpm /home/vagrant/.cache/buildscripts_cache/pkgs/NO_LABEL/lcov-0+1519e3d+untested/cfbuild-lcov-1.15-1.noarch.rpm
#error: Failed dependencies:
#        perl(Digest::MD5) is needed by cfbuild-lcov-1.15-1.noarch
sudo yum install -y perl-Digest-MD5
#        perl(IO::Uncompress::Gunzip) is needed by cfbuild-lcov-1.15-1.noarch
# yum whatprovides "perl(IO::Uncompress::Gunzip)"
sudo yum install -y perl-IO-Compress
#        perl(JSON::PP) is needed by cfbuild-lcov-1.15-1.noarch
# yum whatprovides "perl(JSON:PP)"
sudo yum install -y perl-JSON-PP
# + pkg-install-rpm /home/vagrant/.cache/buildscripts_cache/pkgs/NO_LABEL/lmdb-0+1519e3d+untested/cfbuild-lmdb-0+1519e3d+untested-1.x86_64.rpm /home/vagrant/.cache/buildscripts_cache/pkgs/NO_LABEL/lmdb-0+1519e3d+untested/cfbuild-lmdb-devel-0+1519e3d+untested-1.x86_64.rpm
#Preparing...                          ################################# [100%]
#        file /var/cfengine/bin/lmdump from install of cfbuild-lmdb-0+1519e3d+untested-1.x86_64 conflicts with file from package cfengine-nova-3.18.3-2.el7.x86_64
sudo yum erase -y cfengine-nova
sudo yum erase -y cfengine-nova-hub
sudo yum erase -y cfengine-community
# Can't locate IPC/Cmd.pm in @INC (@INC contains: /home/vagrant/ART/openssl/BUILD/openssl-3.0.7/util/perl /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 . /home/vagrant/ART/openssl/BUILD/openssl-3.0.7/external/perl/Text-Template-1.56/lib) at /home/vagrant/ART/openssl/BUILD/openssl-3.0.7/util/perl/OpenSSL/config.pm line 19.
# yum whatprovides perl-ipc-cmd
sudo yum install -y perl-IPC-Cmd
# +++ grep '^[^a-zA-Z0-9_]VERSION=[^$]*$' /home/vagrant/ART/./core/configure
# grep: /home/vagrant/ART/./core/configure: No such file or directory
# ++ VERSION_IN=
# ++ echo 'Got VERSION: '
# Got VERSION:
# +++ echo ''
# +++ tr - '~'
# ++ VERSION=
# ++ egrep '^[0-9]+\.[0-9]+\.[0-9]+([ab][0-9]*)?(\.[0-9a-f]+)?(~.*)?$'
# ++ echo ''
# ++ echo 'Unable to parse version . Bailing out.'
# Unable to parse version . Bailing out.
# ++ exit 42
sh -x ./buildscripts/build-scripts/unpack-tarballs
sh -x ./buildscripts/build-scripts/install-dependencies
sh -x ./buildscripts/build-scripts/configure
#  /usr/bin/install -c -m 644 systemd/cfengine3.service systemd/cf-apache.service systemd/cf-execd.service systemd/cf-hub.service systemd/cf-reactor.service systemd/cf-monitord.service systemd/cf-postgres.service systemd/cf-runalerts.service systemd/cf-serverd.service '/home/vagrant/ART/./cfengine/dist/usr/lib/systemd/system'
# ==== AUTHENTICATING FOR org.freedesktop.systemd1.reload-daemon ===
# Authentication is required to reload the systemd state.
# Authenticating as: root
# Password:
# polkit-agent-helper-1: pam_authenticate failed: Authentication failure
# ==== AUTHENTICATION FAILED ===
# Failed to execute operation: Access denied
sh -x ./buildscripts/build-scripts/compile

yum erase -y cfbuild-*
rm -rf /var/cfengine
rm -rf /opt/cfengine
./buildscripts/build-scripts/install-dependencies
./buildscripts/build-scripts/package

#uname -a | grep darwin
#sysctl -n hw.ncpu
#| grep linux
#cat /proc/cpuinfo | grep processor | wc -l

#export MAKEFLAGS="-j -l
#alias make='make -j -l${os_cpu_cores}'
./buildscripts/build-scripts/autogen
# TODO remove libtool libtool-ltdl
./buildscripts/build-scripts/clean-buildmachine
./buildscripts/build-scripts/build-environment-check
./buildscripts/build-scripts/install-dependencies
#source /cfe/buildscripts/build-scripts/functions
#source /cfe/buildscripts/build-scripts/compile-options
#source /cfe/buildscripts/build-scripts/detect-environment
./buildscripts/build-scripts/configure
./buildscripts/build-scripts/compile
./buildscripts/build-scripts/package
rm -rf /var/cfengine # TODO why?
ls -l cfengine-community/*.deb
# TEST_MACHINE=chroot doesn't work in a container right?
./buildscripts/build-scripts/clean-buildmachine
./buildscripts/build-scripts/build-environment-check
./buildscripts/build-scripts/install-dependencies
./buildscripts/build-scripts/test

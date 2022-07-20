cd /cfe
./buildscripts/build-scripts/autogen
./buildscripts/build-scripts/clean-buildmachine
./buildscripts/build-scripts/build-environment-check
./buildscripts/build-scripts/install-dependencies
source /cfe/buildscripts/build-scripts/functions
source /cfe/buildscripts/build-scripts/compile-options
source /cfe/buildscripts/build-scripts/detect-environment
./buildscripts/build-scripts/configure
./buildscripts/build-scripts/compile
./buildscripts/build-scripts/package
ls -l cfengine-community/*.deb

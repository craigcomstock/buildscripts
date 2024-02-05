# aka testing-pr
initialize-build-host.sh
./buildscripts/build-scripts/unpack-tarballs
export BUILD_TYPE=DEBUG # or RELEASE
export ESCAPETEST=yes # TODO docs
export TEST_MACHINE=chroot; export TEST_MACHINE # todo docs

./buildscripts/build-scripts/clean-buildmachine &amp;&amp;
./buildscripts/build-scripts/build-environment-check &amp;&amp;
./buildscripts/build-scripts/install-dependencies &amp;&amp;
./buildscripts/build-scripts/configure &amp;&amp;
./buildscripts/build-scripts/generate-source-tarballs &amp;&amp;
./buildscripts/build-scripts/compile &amp;&amp;
./buildscripts/build-scripts/package &amp;&amp;
./buildscripts/build-scripts/prepare-results &amp;&amp;

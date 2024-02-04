# download package cache for platform to avoid sending secrets "over there"
# and speed up build if possible
# the build will need to RETURN any newly built packages to here for secrets to push to package cache
export PATH=$PATH:buildscripts/deps-packaging
pkg-cache listpkgfiles curl-8.4.0 (from each dep, could use install-dependencies with a switch to NOT build from source)
export JOB_BASE_NAME=label=PACKAGES_x86_64_linux_suse_12

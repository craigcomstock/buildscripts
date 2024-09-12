# changes only in buildscripts/packaging? run this!
source sourceme.sh
#./00-clean.sh
# if cfbuild packages are installed, that's where we "want to be" for this
#./60-install-dependencies-from-packages.sh
#./50-compile-cfengine-sources.sh
./70-package.sh
#./00-clean.sh # to prepare for ./90-install.sh

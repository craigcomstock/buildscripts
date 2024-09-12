./01-clean.sh
source sourceme.sh
rm log
./buildscripts/build-scripts/install-dependencies 2>&1 | tee log
./buildscripts/build-scripts/compile 2>&1 | tee log
./buildscripts/build-scripts/package 2>&1 | tee -a log
./01-clean.sh 2>&1 | tee -a log

source sourceme.sh
# changes in core, enterprise, masterfiles, mission-portal, nova? use this!
./00-clean.sh
./20-install-dependencies-from-sftp-cache-or-source.sh
./50-compile-cfengine-sources.sh

./00-clean.sh
# build-dir, package, etc
rm -rf cfengine-nova-hub
# cfengine has dist/(etc, usr, var)
rm -rf cfengine
#rm -rf cfengine-masterfiles*tar.gz
# ^^^ hmmm, just want to take masterfiles instead of the tarball
# maybe just clean out SOME of the bits in there, especially BUILDROOT (like masterfiles)
#rm -rf cfengine-nova-hub # that's a lot! but otherwise we don't get changes from say masterfiles (and others?)

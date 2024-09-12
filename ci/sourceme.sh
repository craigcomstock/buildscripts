export BUILD_TYPE=DEBUG
export PROJECT=nova
export NO_CONFIGURE=1
export ESCAPETEST=yes
export EXPLICIT_ROLE=hub
export TEST_MACHINE=chroot
export JOB_BASE_NAME="label=PACKAGES_HUB_x86_64_linux_redhat_7"

for mingw agent
export BUILD_TYPE=DEBUG
export PROJECT=nova
export NO_CONFIGURE=1
export ESCAPETEST=yes
export EXPLICIT_ROLE=agent
export TEST_MACHINE=chroot
# label is required to detect CROSS_TARGET mingw
export label="PACKAGES_x86_64_mingw"
export JOB_BASE_NAME="label=$label"
export TERM=linux

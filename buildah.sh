b=debian-working-container-1
for repo in core masterfiles nova enterprise mission-portal buildscripts; do
  buildah copy $b /northern.tech/$repo /cfe/$repo
done

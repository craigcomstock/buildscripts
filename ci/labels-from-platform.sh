platform=$1
plat=$(echo $platform | sed 's/-/_/')
grep $plat ../build-scripts/labels.txt

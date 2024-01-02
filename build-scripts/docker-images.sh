#!/usr/bin/env bash
set -ex

version=${1:-master}
dist=ubuntu
dist_version=22
packages="$HOME/.cfengine/cf-remote/packages"

cat <<EOF >Dockerfile-systemd
FROM $dist:$dist_version
RUN apt-get update && apt-get install -q -y systemd wget sudo
CMD [ "/lib/systemd/systemd" ]
EOF

cf-remote --version $version download $dist$dist_version amd64
urls="$(cf-remote --version $version list $dist$dist_version amd64 | grep http)"
for url in $urls; do
  base=$(basename $url)
  if echo "$base" | grep hub; then
    hub_package="$base"
  else
    agent_package="$base"
  fi
done
for install_type in hub agent; do
  name="cfengine-"$install_type
  if docker ps -a | grep $name; then
    docker ps -a | grep $name | awk '{print $1}' | xargs docker stop
    docker ps -a | grep $name | awk '{print $1}' | xargs docker rm
  fi
  if docker images | grep $name; then
    docker images | grep $name | awk '{print $3}' | xargs docker rmi --force
  fi
  
  docker build -t $name -f Dockerfile-systemd .
  docker run -d --privileged --name $name $name
  docker exec -i $name bash -c "$release_env wget https://s3.amazonaws.com/cfengine.packages/quick-install-cfengine-enterprise.sh  && sudo bash ./quick-install-cfengine-enterprise.sh $install_type"
  if [ "$install_type" = "hub" ]; then
    docker copy "$packages"/"$hub_package" -i $name
    docker exec -i $name bash -c "dpkg -i /$hub_package"
    docker exec -i $name bash -c "/var/cfengine/bin/cf-agent -KI \$(hostname -i)"
  else
    docker copy "$packages"/"$agent_package" -i $name
    docker exec -i $name bash -c "dpkg -i /$agent_package"
  fi
  docker commit $name $name:latest
  docker image tag $name:latest cfengine/$name:latest
#  docker image push cfengine/$name:latest
  docker stop $name
  docker rm $name
  docker rmi $name
done

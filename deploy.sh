#!/bin/bash
set -e

backend_service_name="server"

deploy() {
  if [ -z "$1" ]; then
    read -r -p "Enter version you want to deploy: " version
  else
    version=$1
  fi

  if [ -z "$version" ]; then
    echo "You did not enter a version."
    exit 1
  fi

  export VERSION=$version

  echo "Start deploy backend version $version...."
  old_container_id=$(docker ps -f name=$backend_service_name -q | tail -n1)

  echo "Create new container"
  docker-compose up -d --no-deps --scale $backend_service_name=2 --no-recreate $backend_service_name

  echo -e "\nStart routing requests to the new container"
  reload_nginx

  echo "Checking if old container exists..."
  if [ -n "$old_container_id" ]; then
    echo "Removing old container $old_container_id"
    docker stop $old_container_id
    docker rm $old_container_id
    echo "Old container removed"
  fi

  echo "Setting scale to 1"
  docker-compose up -d --no-deps --scale $backend_service_name=1 --no-recreate $backend_service_name

  echo "Deploy backend version $version successfully!!!"

  echo "Cleaning up unused images"
  docker image prune -a -f
}

deploy $1
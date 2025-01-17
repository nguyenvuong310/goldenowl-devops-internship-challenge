#!/bin/bash

# Stop on error
set -e
echo "Start build ...."

# Check build branch
current_branch=$(git branch --show-current)
echo "Checking build branch with $current_branch ..."

if [ "$current_branch" != "feature" ]; then
  echo "Not on the feature branch. Aborting the build."
  exit 1
fi

DOCKER_IMAGE_NAME="vuong676/devops-intern-assignment-ntv"
DOCKER_USERNAME="vuong676"
DOCKER_TAG=$(git rev-parse --short HEAD)

echo "Logging into DockerHub..."
docker login -u $DOCKER_USERNAME -p $DOCKER_PASS

echo "Building Docker image: $DOCKER_IMAGE_NAME:$DOCKER_TAG ..."
docker build -t $DOCKER_IMAGE_NAME:$DOCKER_TAG ./src --platform linux/amd64

echo "Pushing Docker image to DockerHub..."
docker push $DOCKER_IMAGE_NAME:$DOCKER_TAG

echo "Docker image built and pushed successfully."
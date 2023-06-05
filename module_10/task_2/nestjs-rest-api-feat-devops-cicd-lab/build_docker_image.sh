#!/bin/bash

DOCKER_REPO="epamyahorhlushak/devops-traning"

BRANCH=$(git rev-parse --abbrev-ref HEAD)
VERSION=$(jq -r '.version' package.json)

TAG_NAME="${BRANCH}_${VERSION}"
TAG_NAME=${TAG_NAME//_/-}

echo "Image tag: $TAG_NAME"

docker build -t ${DOCKER_REPO}:${TAG_NAME} .
docker push ${DOCKER_REPO}:${TAG_NAME}

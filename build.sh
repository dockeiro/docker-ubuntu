#!/bin/bash
# echo $DOCKERPASS | docker login -u $DOCKERUSER --password-stdin

# Variables
APP_VERSION=$(cat VERSION)
IMAGE_DEST='dockeirorock/ubuntu'
ARCH_HOST=$(dpkg --print-architecture)

echo +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
echo += VERSION loaded: ${APP_VERSION}
echo +=   IMAGE loaded: ${IMAGE_DEST}
echo +=    ARCH loaded: ${ARCH_HOST}
echo +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
sleep 10

docker build --no-cache --rm --pull \
--build-arg IMAGE=${IMAGE_DEST} \
--build-arg BUILD_DATE=\"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\" \
--build-arg VERSION=${APP_VERSION} \
--build-arg VCS_REF=\"$(git rev-parse --short HEAD)\" \
--build-arg VCS_URL=\"$(git config --get remote.origin.url)\" \
--build-arg ARCH=${ARCH_HOST} \
--tag ${IMAGE_DEST}:${APP_VERSION}-${ARCH_HOST} .
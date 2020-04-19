#!/bin/bash
# echo $DOCKERPASS | docker login -u $DOCKERUSER --password-stdin

# Variables
IMAGE='dockeirorock/ubuntu'
VERSION=$(cat VERSION)

docker pull ${IMAGE}:${VERSION}-amd64
docker pull ${IMAGE}:${VERSION}-arm64
docker pull ${IMAGE}:${VERSION}-armhf

docker tag ${IMAGE}:${VERSION}-amd64 ${IMAGE}:${VERSION}-amd64-latest
docker tag ${IMAGE}:${VERSION}-arm64 ${IMAGE}:${VERSION}-arm64-latest
docker tag ${IMAGE}:${VERSION}-armhf ${IMAGE}:${VERSION}-armhf-latest

docker push ${IMAGE}:${VERSION}-amd64
docker push ${IMAGE}:${VERSION}-arm64
docker push ${IMAGE}:${VERSION}-armhf
docker push ${IMAGE}:${VERSION}-amd64-latest
docker push ${IMAGE}:${VERSION}-arm64-latest
docker push ${IMAGE}:${VERSION}-armhf-latest

docker manifest push --purge ${IMAGE}:latest || :
docker manifest create ${IMAGE}:latest ${IMAGE}:${VERSION}-amd64-latest ${IMAGE}:${VERSION}-armhf-latest ${IMAGE}:${VERSION}-arm64-latest
docker manifest annotate ${IMAGE}:latest ${IMAGE}:${VERSION}-armhf-latest --os linux --arch arm
docker manifest annotate ${IMAGE}:latest ${IMAGE}:${VERSION}-arm64-latest --os linux --arch arm64 --variant v8

docker manifest push --purge ${IMAGE}:${VERSION} || :
docker manifest create ${IMAGE}:${VERSION} ${IMAGE}:${VERSION}-amd64 ${IMAGE}:${VERSION}-armhf ${IMAGE}:arm64-VERSION
docker manifest annotate ${IMAGE}:${VERSION} ${IMAGE}:${VERSION}-armhf --os linux --arch arm
docker manifest annotate ${IMAGE}:${VERSION} ${IMAGE}:arm64-VERSION --os linux --arch arm64 --variant v8

docker manifest push --purge ${IMAGE}:latest
docker manifest push --purge ${IMAGE}:${VERSION}

docker rmi \
${IMAGE}:${VERSION}-amd64 \
${IMAGE}:${VERSION}-arm64 \
${IMAGE}:${VERSION}-armhf \
${IMAGE}:${VERSION}-armhf-latest \
${IMAGE}:${VERSION}-amd64-latest \
${IMAGE}:${VERSION}-arm64-latest
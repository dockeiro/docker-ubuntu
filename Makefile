TARGETS := $(shell cat $(realpath $(lastword $(MAKEFILE_LIST))) | grep "^[a-z]*:" | awk '{ print $$1; }' | sed 's/://g' | grep -vE 'all|help' | paste -sd "|" -)
NAME := $(subst docker-,,$(shell basename $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))))
IMAGE := dockeirorock/$(NAME)

all: help

help:
	echo
	echo "Usage:"
	echo
	echo "    make $(TARGETS) [APT_PROXY|APT_PROXY_SSL=ip:port]"
	echo

build:
	docker build \
		--build-arg APT_PROXY=$(APT_PROXY) \
		--build-arg APT_PROXY_SSL=$(APT_PROXY_SSL) \
		--build-arg IMAGE=$(IMAGE) \
		--build-arg BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ") \
		--build-arg VERSION=$(shell cat VERSION) \
		--build-arg VCS_REF=$(shell git rev-parse --short HEAD) \
		--build-arg VCS_URL=$(shell git config --get remote.origin.url) \
		--build-arg ARCH=amd64 \
		--tag $(IMAGE):$(shell cat VERSION)-amd64 \
		--rm .
	docker buildx build --no-cache \
		--build-arg APT_PROXY=$(APT_PROXY) \
		--build-arg APT_PROXY_SSL=$(APT_PROXY_SSL) \
		--build-arg IMAGE=$(IMAGE) \
		--build-arg BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ") \
		--build-arg VERSION=$(shell cat VERSION) \
		--build-arg VCS_REF=$(shell git rev-parse --short HEAD) \
		--build-arg VCS_URL=$(shell git config --get remote.origin.url) \
		--build-arg ARCH=armhf \
		--tag $(IMAGE):$(shell cat VERSION)-armhf \
		--rm \
		--platform=linux/arm .
	docker buildx build --no-cache \
		--build-arg APT_PROXY=$(APT_PROXY) \
		--build-arg APT_PROXY_SSL=$(APT_PROXY_SSL) \
		--build-arg IMAGE=$(IMAGE) \
		--build-arg BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ") \
		--build-arg VERSION=$(shell cat VERSION) \
		--build-arg VCS_REF=$(shell git rev-parse --short HEAD) \
		--build-arg VCS_URL=$(shell git config --get remote.origin.url) \
		--build-arg ARCH=arm64 \
		--tag $(IMAGE):$(shell cat VERSION)-aarch64 \
		--rm \
		--platform=linux/arm64 .
	docker manifest create $(IMAGE):latest \
	--amend $(IMAGE):$(shell cat VERSION)-amd64 \
	--amend $(IMAGE):$(shell cat VERSION)-armhf \
	--amend $(IMAGE):$(shell cat VERSION)-aarch64
	docker manifest annotate $(IMAGE):latest $(IMAGE):$(shell cat VERSION)-armhf --os linux --arch arm
	docker manifest annotate $(IMAGE):latest $(IMAGE):$(shell cat VERSION)-aarch64 --os linux --arch arm64 --variant v8
	docker manifest create $(IMAGE):$(shell cat VERSION) \
	--amend $(IMAGE):$(shell cat VERSION)-amd64 \
	--amend $(IMAGE):$(shell cat VERSION)-armhf \
	--amend $(IMAGE):$(shell cat VERSION)-aarch64
	docker manifest annotate $(IMAGE):$(shell cat VERSION) $(IMAGE):$(shell cat VERSION)-armhf --os linux --arch arm
	docker manifest annotate $(IMAGE):$(shell cat VERSION) $(IMAGE):$(shell cat VERSION)-aarch64 --os linux --arch arm64 --variant v8
	docker rmi --force $$(docker images | grep "<none>" | awk '{ print $$3 }') 2> /dev/null ||:

start:
	docker run --detach --interactive --tty \
		--name $(NAME) \
		--hostname $(NAME) \
		--env "INIT_DEBUG=true" \
		$(IMAGE) \
		/bin/bash --login

stop:
	docker stop $(NAME) > /dev/null 2>&1 ||:
	docker rm --volumes $(NAME) > /dev/null 2>&1 ||:

log:
	docker logs --follow $(NAME)

test:
	docker run --interactive --tty --rm $(IMAGE) \
		date | grep -v "UTC"
	docker run --interactive --tty --rm $(IMAGE) \
		locale | grep "LANG=C.UTF-8"
	docker run --interactive --tty --rm $(IMAGE) \
		ps aux | grep "default.\+ps aux"
	docker run --interactive --tty --rm --env "INIT_DEBUG=true" $(IMAGE) \
		echo | grep "exec.\+echo"
	docker run --interactive --tty --rm --env "INIT_GOSU=true" $(IMAGE) \
		ps aux | grep "default.\+ps aux"
	docker run --interactive --tty --rm --env "INIT_GOSU=false" $(IMAGE) \
		ps aux | grep "root.\+ps aux"
	docker run --interactive --tty --rm --env "INIT_RUN_AS=root" $(IMAGE) \
		ps aux | grep "root.\+ps aux"
	docker run --interactive --tty --rm --env "INIT_RUN_AS=root" $(IMAGE) \
		ls /root/dotfiles | grep "/root/dotfiles"

bash:
	docker exec --interactive --tty \
		--user root \
		$(NAME) \
		/bin/bash --login ||:

clean:
	docker rmi --force $(IMAGE):latest > /dev/null 2>&1 ||:
	docker rmi --force $(IMAGE):$(shell cat VERSION) > /dev/null 2>&1 ||:
	docker rmi --force $(IMAGE):$(shell cat VERSION)-armhf > /dev/null 2>&1 ||:
	docker rmi --force $(IMAGE):$(shell cat VERSION)-aarch64 > /dev/null 2>&1 ||:
	docker rmi --force $(IMAGE):$(shell cat VERSION)-amd64 > /dev/null 2>&1 ||:
	docker rmi --force $$(docker images | grep "<none>" | awk '{ print $$3 }') 2> /dev/null ||:

push:
	docker manifest push $(IMAGE):latest 
	docker manifest push $(IMAGE):$(shell cat VERSION)
	docker push $(IMAGE):$(shell cat VERSION)-armhf
	docker push $(IMAGE):$(shell cat VERSION)-aarch64
	docker push $(IMAGE):$(shell cat VERSION)-amd64

.SILENT: help

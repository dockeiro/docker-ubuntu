[![Circle CI](https://circleci.com/gh/codeworksio/docker-ubuntu.svg?style=shield "CircleCI")](https://circleci.com/gh/codeworksio/docker-ubuntu)&nbsp;[![Size](https://images.microbadger.com/badges/image/codeworksio/ubuntu.svg)](http://microbadger.com/images/codeworksio/ubuntu)&nbsp;[![Version](https://images.microbadger.com/badges/version/codeworksio/ubuntu.svg)](http://microbadger.com/images/codeworksio/ubuntu)&nbsp;[![Commit](https://images.microbadger.com/badges/commit/codeworksio/ubuntu.svg)](http://microbadger.com/images/codeworksio/ubuntu)&nbsp;[![Docker Hub](https://img.shields.io/docker/pulls/codeworksio/ubuntu.svg)](https://hub.docker.com/r/codeworksio/ubuntu/)

Docker Ubuntu
=============

Customised Ubuntu base image.

Installation
------------

Builds of the image are available on [Docker Hub](https://hub.docker.com/r/codeworksio/ubuntu/).

    docker pull codeworksio/ubuntu

Alternatively you can build the image yourself.

    docker build --tag codeworksio/ubuntu \
        github.com/codeworksio/docker-ubuntu

Configuration
-------------

* On build triggers are set to copy entrypoint resources
    - `assets/sbin/bootstrap.sh`
    - `assets/sbin/init.d/*.sh`
    - `assets/sbin/init.sh`
* `/sbin/entrypoint.sh` is defined as the entrypoint
* `/sbin/bootstrap.sh` is sourced if present
* `/sbin/init.d/*.sh` are sourced if present
* Use for example `CMD [ "/sbin/init.sh" ]` in a child image to run your process
* Docker environment variables
    - `INIT_DEBUG=true` enable verbose output
    - `INIT_TRACE=true` pass the main process to `strace` (use along with `--privileged`)
    - `INIT_RUN_AS=root` start the main process as a privileged user
    - `INIT_GOSU=true` make use of `gosu` (default)
* Docker runtime flags
    - `--privileged` give container extended privileges
    - `--cap-add`, `--cap-drop` control Linux kernel capabilities

Testing
-------

    make build start bash

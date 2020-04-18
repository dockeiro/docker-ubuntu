[![Circle CI](https://circleci.com/gh/dockeirorock/docker-ubuntu.svg?style=shield "CircleCI")](https://circleci.com/gh/dockeirorock/docker-ubuntu)&nbsp;[![Size](https://images.microbadger.com/badges/image/dockeirorock/ubuntu.svg)](http://microbadger.com/images/dockeirorock/ubuntu)&nbsp;[![Version](https://images.microbadger.com/badges/version/dockeirorock/ubuntu.svg)](http://microbadger.com/images/dockeirorock/ubuntu)&nbsp;[![Commit](https://images.microbadger.com/badges/commit/dockeirorock/ubuntu.svg)](http://microbadger.com/images/dockeirorock/ubuntu)&nbsp;[![Docker Hub](https://img.shields.io/docker/pulls/dockeirorock/ubuntu.svg)](https://hub.docker.com/r/dockeirorock/ubuntu/)

Docker Ubuntu
=============

Customised Ubuntu base image.

Installation
------------

Builds of the image are available on [Docker Hub](https://hub.docker.com/r/dockeirorock/ubuntu/).

    docker pull dockeirorock/ubuntu

Alternatively you can build the image yourself.

    docker build --tag dockeirorock/ubuntu \
        github.com/dockeiro/docker-ubuntu

Configuration
-------------

* `/sbin/entrypoint.sh` is defined as the entrypoint
* `/sbin/init.d/*.sh` are sourced if present
* Use for example `CMD [ "/sbin/init.sh" ]` in a child image to run your process
* Docker environment variables
    - `INIT_DEBUG=true` enable verbose output
    - `INIT_TRACE=true` pass the main process to `strace` (use along with the Docker flag `--privileged`)
    - `INIT_RUN_AS=root` start the main process as a privileged user
    - `INIT_GOSU=true` make use of `gosu` (default)

Testing
-------

    make build start bash
    make stop

TODO
----

* Check if [Linux Enhanced BPF (eBPF)](http://www.brendangregg.com/ebpf.html) can provide better tracing than `strace`

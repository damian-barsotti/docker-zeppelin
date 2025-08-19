#!/bin/bash
set -x
IM_VERSION=3.1

DIRNAME="$(dirname "$0")"
GIT_DIR="$(realpath "$DIRNAME")"

DOCKER_GIT_DIR="$GIT_DIR"
DOCKER_VOLS_DIR="$DOCKER_GIT_DIR"/vols

CONF_DIR="$DOCKER_VOLS_DIR"/conf
NOTEBOOK_DIR="$DOCKER_VOLS_DIR"/notebook

exec docker run -it --rm --hostname localhost -p 8080:8080 -p 4040:4040 \
    -v "$CONF_DIR":/opt/zeppelin/conf \
    -v "$NOTEBOOK_DIR":/opt/zeppelin/notebook \
    -e ZEPPELIN_INTERPRETER_CONNECT_TIMEOUT=120000 \
    --name diplodatos_bigdata diplodatos/bigdata:$IM_VERSION

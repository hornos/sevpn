#!/usr/bin/env bash

PLATFORM=${PLATFORM:-amd64}
NAME=sevpn
TARGET=${NAME}:$PLATFORM

function help() {
  cat<<EOF

This scripts builds a devel Docker image for the $PLATFORM platform. Check the
docker directory for the Dockerfile.

EOF
  exit 1
}

function build_docker() {
  echo
  echo "Building Docker Image"
  docker buildx build --platform linux/${PLATFORM} -t $TARGET ./docker/${PLATFORM}
  echo
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
  help
fi

build_docker

#!/bin/bash -e

function on_exit() {
  if [[ -n "${IMAGE}" ]]; then
    docker rmi "${IMAGE}"
  fi
}

function usage() {
  echo "usage: $0 ubuntu-version"
}

VERSION="$1"

DOCKERFILE="FROM ubuntu:${VERSION}
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    qt6-base-dev \
    qt6-webengine-dev \
    qt6-webview-dev \
    qt6-webengine-dev-tools \
    build-essential \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libxkbcommon-dev \
    libvulkan-dev \
    cmake \
    g++ \
"

trap on_exit EXIT

docker build - <<< "${DOCKERFILE}"
IMAGE="$(docker build -q - <<< "${DOCKERFILE}")"

# Clean dynamically created build files
rm -rf \
  .qt \
  .qt_plugins \
  CMakeCache.txt \
  CMakeFiles \
  cmake_install.cmake \
  openfortivpn-webview_autogen \
  Makefile

# Run build
docker run --rm -u "$(stat -c '%u:%g' .)" -v "${PWD}:${PWD}" --workdir "${PWD}" "${IMAGE}" bash -c 'cmake . && make'

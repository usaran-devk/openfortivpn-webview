#!/bin/bash

function on_exit() {
  if [[ -n "${IMAGE}" ]]; then
    docker rmi "${IMAGE}"
  fi
}


BASE_IMAGE="opensuse/leap:15.6"

DOCKERFILE="FROM ${BASE_IMAGE}
RUN zypper --non-interactive install qt6-webview-devel qt6-widgets-devel qt6-webenginewidgets-devel cmake"

trap on_exit EXIT

docker build - <<< "${DOCKERFILE}"
IMAGE="$(docker build -q - <<< "${DOCKERFILE}")"

docker run --rm -u "$(stat -c '%u:%g' .)" -v "${PWD}:${PWD}" --workdir "${PWD}" "${IMAGE}" bash -c 'cmake . && make'

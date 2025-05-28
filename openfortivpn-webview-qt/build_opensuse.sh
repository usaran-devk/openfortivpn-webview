#!/bin/bash -e

function on_exit() {
  if [[ -n "${IMAGE}" ]]; then
    docker rmi "${IMAGE}"
  fi
}

function usage() {
  echo "usage: $0 leap|tumbleweed [ leap-version ]"
}

VARIANT="$1"
VERSION="$2"

case "${VARIANT}" in
    "tumbleweed")
    BASE_IMAGE="opensuse/tumbleweed"
    ;;

    "leap")
      [[ -n "${VERSION}" ]] || { usage; exit 1; }
      BASE_IMAGE="opensuse/leap:${VERSION}"
      ;;
    *)
      usage
      exit 1
esac

DOCKERFILE="FROM ${BASE_IMAGE}
RUN zypper --non-interactive install qt6-webview-devel qt6-widgets-devel qt6-webenginewidgets-devel cmake"

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

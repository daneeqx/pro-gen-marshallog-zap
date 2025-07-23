#!/bin/sh
set -e

BUF_IMAGE="${BUF_IMAGE:-reg.nsrv.io/platform/infra/subsystems/gitlab/iac/containers/protoc:5.0.11-deviambrkkdn}"
HOST_CACHE_DIR="${BUF_CACHE_DIR:-$HOME/.cache/buf}"
mkdir -p "${HOST_CACHE_DIR}"

if [ "${BUF_LOCAL:-0}" = "1" ]; then
  buf "$@"
else
  docker run \
    --rm \
    -i \
    -v "$(pwd):$(pwd)" \
    -v "${HOST_CACHE_DIR}:/.cache" \
    -e "BUF_CACHE_DIR=/.cache" \
    -u "$(id -u):$(id -g)" \
    -w "$(pwd)" \
    --entrypoint "/usr/local/bin/buf" \
    "${BUF_IMAGE}" \
    "$@"
fi

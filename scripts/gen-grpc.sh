#!/bin/sh

set -e

SCRIPT_DIR=$(realpath $(dirname $0))
cd ${SCRIPT_DIR}/../


rm -rf ./gen/api

generate() {
    echo "Generating $1"
    ./scripts/buf.sh generate --template scripts/buf.gen/$1
}

generate grpc.yaml

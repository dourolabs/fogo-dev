#!/bin/bash

set -e

trap 'echo "Error on line $LINENO"' ERR

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FOGO_DIR="$WORKSPACE_DIR/fogo"
CURRENT_DIR=$(pwd)

cd "$FOGO_DIR"

make -j fdctl

cd "$CURRENT_DIR"

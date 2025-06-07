#!/bin/bash

set -e

trap 'echo "Error on line $LINENO"' ERR

RELEASE=${1:-"fogo-v6.0.0"}

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FOGO_DIR="$WORKSPACE_DIR/fogo"

if [ -d "$FOGO_DIR" ]; then
    echo "Fogo directory already exists at $FOGO_DIR"
    echo "Remove $FOGO_DIR and run this script again to download fresh copy"
    exit 1
else
    echo "Downloading fogo tarball..."
    TARBALL_URL="https://static.fogo.io/$RELEASE.tar.gz"
    TEMP_DIR=$(mktemp -d)

    curl -L "$TARBALL_URL" -o "$TEMP_DIR/fogo.tar.gz"

    echo "Extracting tarball..."
    mkdir -p "$FOGO_DIR"
    tar -xzf "$TEMP_DIR/fogo.tar.gz" -C "$FOGO_DIR" --strip-components=1
    rm -rf "$TEMP_DIR"
fi

echo "Installing dependencies..."
CURRENT_DIR=$(pwd)
if [ -f "$FOGO_DIR/deps.sh" ]; then
    cd "$FOGO_DIR"
    yes | ./deps.sh
    cd "$CURRENT_DIR"
else
    echo "Warning: deps.sh not found in fogo directory"
fi

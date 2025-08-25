#!/bin/bash

# Architecture detection script
# Returns the architecture to use for building (amd64 or arm64)

# Use GOARCH (CI) or ARCHITECTURE (local) from environment, default to host architecture if not set
if [ -n "$GOARCH" ]; then
    echo "$GOARCH"
elif [ -n "$ARCHITECTURE" ]; then
    echo "$ARCHITECTURE"
else
    HOST_ARCH=$(uname -m)
    case $HOST_ARCH in
        x86_64)
            echo "amd64"
            ;;
        arm64|aarch64)
            echo "arm64"
            ;;
        *)
            echo "Unsupported architecture: $HOST_ARCH" >&2
            exit 1
            ;;
    esac
fi

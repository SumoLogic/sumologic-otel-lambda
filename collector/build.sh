#!/bin/bash

# Copy changed files

cp ./src/main.go ../opentelemetry-lambda/collector
cp ./src/internal/telemetryapi/listener.go ../opentelemetry-lambda/collector/internal/telemetryapi/listener.go

# Build collector

pushd ../opentelemetry-lambda/collector || exit
make install-tools
make gofmt
make package
popd || exit

# Add config.yaml

# Use GOARCH (CI) or ARCHITECTURE (local) from environment, default to host architecture if not set
if [ -n "$GOARCH" ]; then
    ARCH_TO_USE="$GOARCH"
elif [ -n "$ARCHITECTURE" ]; then
    ARCH_TO_USE="$ARCHITECTURE"
else
    HOST_ARCH=$(uname -m)
    case $HOST_ARCH in
        x86_64)
            ARCH_TO_USE="amd64"
            ;;
        arm64|aarch64)
            ARCH_TO_USE="arm64"
            ;;
        *)
            echo "Unsupported architecture: $HOST_ARCH"
            exit 1
            ;;
    esac
fi

cp ../opentelemetry-lambda/collector/build/opentelemetry-collector-layer-${ARCH_TO_USE}.zip .
unzip -qo opentelemetry-collector-layer-${ARCH_TO_USE}.zip
rm opentelemetry-collector-layer-${ARCH_TO_USE}.zip
cp ./config/config.yaml ./collector-config/config.yaml
zip -r collector-layer.zip collector-config extensions

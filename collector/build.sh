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

# Use ARCHITECTURE from environment, default to host architecture if not set
if [ -z "$ARCHITECTURE" ]; then
    HOST_ARCH=$(uname -m)
    case $HOST_ARCH in
        x86_64)
            GOARCH="amd64"
            ;;
        arm64|aarch64)
            GOARCH="arm64"
            ;;
        *)
            echo "Unsupported architecture: $HOST_ARCH"
            exit 1
            ;;
    esac
else
    GOARCH="$ARCHITECTURE"
fi

cp ../opentelemetry-lambda/collector/build/opentelemetry-collector-layer-${GOARCH}.zip .
unzip -qo opentelemetry-collector-layer-${GOARCH}.zip
rm opentelemetry-collector-layer-${GOARCH}.zip
cp ./config/config.yaml ./collector-config/config.yaml
zip -r collector-layer.zip collector-config extensions

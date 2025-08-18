#!/bin/bash

# Copy changed files

cp ./src/main.go ../opentelemetry-lambda/collector
cp ./src/internal/telemetryapi/listener.go ../opentelemetry-lambda/collector/internal/telemetryapi/listener.go

# Detect architecture to use for building
ARCH_TO_USE=$(./detect-arch.sh)

# Build collector

pushd ../opentelemetry-lambda/collector || exit
make install-tools
make gofmt
make build
# Package manually to fix config
mkdir -p build/collector-config
cp ../../collector/config/config.yaml build/collector-config/config.yaml
cd build && zip -r opentelemetry-collector-layer-${ARCH_TO_USE}.zip collector-config extensions
popd || exit

# Add config.yaml

cp ../opentelemetry-lambda/collector/build/opentelemetry-collector-layer-${ARCH_TO_USE}.zip .
unzip -qo opentelemetry-collector-layer-${ARCH_TO_USE}.zip
rm opentelemetry-collector-layer-${ARCH_TO_USE}.zip
cp ./config/config.yaml ./collector-config/config.yaml
zip -r collector-layer.zip collector-config extensions

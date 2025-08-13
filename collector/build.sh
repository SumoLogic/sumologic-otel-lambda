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

# Detect architecture to use for building
ARCH_TO_USE=$(./detect-arch.sh)

cp ../opentelemetry-lambda/collector/build/opentelemetry-collector-layer-${ARCH_TO_USE}.zip .
unzip -qo opentelemetry-collector-layer-${ARCH_TO_USE}.zip
rm opentelemetry-collector-layer-${ARCH_TO_USE}.zip
cp ./config/config.yaml ./collector-config/config.yaml
zip -r collector-layer.zip collector-config extensions

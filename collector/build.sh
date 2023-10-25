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

cp ../opentelemetry-lambda/collector/build/opentelemetry-collector-layer-${GOARCH}.zip .
unzip -qo opentelemetry-collector-layer-${GOARCH}.zip
rm opentelemetry-collector-layer-${GOARCH}.zip
cp ./config/config.yaml ./collector-config/config.yaml
zip -r collector-layer.zip collector-config extensions

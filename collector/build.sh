#!/bin/bash

# Build collector

pushd ../opentelemetry-lambda/collector || exit
make package
popd || exit

# Add config.yaml

cp ../opentelemetry-lambda/collector/build/collector-extension-${GOARCH}.zip .
unzip -qo collector-extension-${GOARCH}.zip
rm collector-extension-${GOARCH}.zip
cp ./config/config.yaml ./collector-config/config.yaml
zip -r collector-layer.zip collector-config extensions

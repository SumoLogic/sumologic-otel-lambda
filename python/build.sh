#!/bin/bash

# Build collector

pushd ../collector || exit
./build.sh
popd || exit

# Build python sdk

pushd ../opentelemetry-lambda/python/src || exit
./build.sh
popd || exit

# Copy requirements.txt https://github.com/psf/requests/issues/6443

cp sample-apps/function/requirements.txt ../opentelemetry-lambda/python/sample-apps/function/requirements.txt

# Build python sample app
pushd ../opentelemetry-lambda/python/sample-apps || exit
./build.sh
popd || exit

# Combine collector extension with nodejs sdk
## Copy and extract all files
mkdir combine
cp ../collector/collector-layer.zip ./combine
cp ../opentelemetry-lambda/python/src/build/opentelemetry-python-layer.zip ./combine

unzip -qo combine/collector-layer.zip -d combine
rm combine/collector-layer.zip
unzip -qo combine/opentelemetry-python-layer.zip -d combine
rm combine/opentelemetry-python-layer.zip

## Copy scripts
cp scripts/otel-instrument combine/otel-instrument

## Combine collector and nodejs sdk 
cd combine || exit; zip -qr ../opentelemetry-python-${ARCHITECTURE}.zip ./*

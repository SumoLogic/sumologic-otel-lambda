#!/bin/bash

# Build collector

pushd ../collector || exit
./build.sh
popd || exit

# Build the Java SDK wrapper layer

pushd ../opentelemetry-lambda/java || exit
./gradlew :layer-wrapper:build
./gradlew :sample-apps:aws-sdk:build
popd || exit

# Combine collector extension with Java SDK wrapper
## Copy and extract all files
mkdir combine
cp ../collector/collector-layer.zip ./combine
cp ../opentelemetry-lambda/java/layer-wrapper/build/distributions/opentelemetry-java-wrapper.zip ./combine

unzip -qo combine/collector-layer.zip -d combine
rm combine/collector-layer.zip
unzip -qo combine/opentelemetry-java-wrapper.zip -d combine
rm combine/opentelemetry-java-wrapper.zip

## Copy scripts
cp scripts/otel-handler combine/otel-handler
cp scripts/otel-proxy-handler combine/otel-proxy-handler
cp scripts/otel-stream-handler combine/otel-stream-handler

## Combine collector and Java SDK wrapper 
cd combine || exit; zip -qr ../opentelemetry-java-wrapper-${ARCHITECTURE}.zip ./*

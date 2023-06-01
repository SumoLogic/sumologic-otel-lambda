#!/bin/bash

# Build collector

pushd ../collector || exit
./build.sh
popd || exit

# Copy wrapper.ts

cp ./packages/layer/src/wrapper.ts ../opentelemetry-lambda/nodejs/packages/layer/src/wrapper.ts

# Copy package.json

cp ./packages/layer/package.json ../opentelemetry-lambda/nodejs/packages/layer/package.json

# Build nodejs sdk

pushd ../opentelemetry-lambda/nodejs || exit
npm install
popd || exit

# Combine collector extension with nodejs sdk
## Copy and extract all files
mkdir combine
cp ../collector/collector-layer.zip ./combine
cp ../opentelemetry-lambda/nodejs/packages/layer/build/layer.zip ./combine

unzip -qo combine/collector-layer.zip -d combine
rm combine/collector-layer.zip
unzip -qo combine/layer.zip -d combine
rm combine/layer.zip

## Copy scripts
cp scripts/otel-handler combine/otel-handler

## Combine collector and nodejs sdk 
cd combine || exit; zip -qr ../opentelemetry-nodejs-${ARCHITECTURE}.zip ./*

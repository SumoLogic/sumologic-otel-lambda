#!/bin/bash

# Detect or use provided architecture
if [ -z "$ARCHITECTURE" ]; then
    # Auto-detect host architecture if ARCHITECTURE not set
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            ARCHITECTURE="amd64"
            ;;
        arm64|aarch64)
            ARCHITECTURE="arm64"
            ;;
        *)
            echo "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac
    echo "Auto-detected architecture: $ARCHITECTURE"
else
    echo "Using provided architecture: $ARCHITECTURE"
fi

# Export for use in collector build
export ARCHITECTURE
export GOARCH=$ARCHITECTURE

# Build collector

pushd ../collector || exit
./build.sh
popd || exit

# Copy wrapper.ts
cp ./packages/layer/src/wrapper.ts ../opentelemetry-lambda/nodejs/packages/layer/src/wrapper.ts

# Copy package.json
cp ./packages/layer/package.json ../opentelemetry-lambda/nodejs/packages/layer/package.json

# Copy global.d.ts with type declarations
cp ./packages/layer/src/global.d.ts ../opentelemetry-lambda/nodejs/packages/layer/src/global.d.ts

# Copy other necessary configuration files
cp ./packages/layer/webpack.config.js ../opentelemetry-lambda/nodejs/packages/layer/webpack.config.js 2>/dev/null || true
cp ./packages/layer/tsconfig.webpack.json ../opentelemetry-lambda/nodejs/packages/layer/tsconfig.webpack.json 2>/dev/null || true
cp ./packages/layer/install-externals.sh ../opentelemetry-lambda/nodejs/packages/layer/install-externals.sh 2>/dev/null || true
chmod +x ../opentelemetry-lambda/nodejs/packages/layer/install-externals.sh 2>/dev/null || true

# Build nodejs sdk and sample apps
pushd ../opentelemetry-lambda/nodejs || exit
npm install
# Build all packages including sample apps with lerna
npm run build
popd || exit

# Combine collector extension with nodejs sdk
## Copy and extract all files
mkdir combine
cp ../collector/collector-layer.zip ./combine/collector-layer.zip
cp ../opentelemetry-lambda/nodejs/packages/layer/build/layer.zip ./combine

unzip -qo combine/collector-layer.zip -d combine
rm combine/collector-layer.zip
unzip -qo combine/layer.zip -d combine
rm combine/layer.zip

## Copy scripts
cp scripts/otel-handler combine/otel-handler

## Combine collector and nodejs sdk 
cd combine || exit; zip -qr ../opentelemetry-nodejs-${ARCHITECTURE}.zip ./*

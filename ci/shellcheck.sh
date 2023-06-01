#!/usr/bin/env bash

set -e

echo "Checking the bash scripts with shellcheck..."
files=$(find . -name '*.sh' -type 'f' -not -path "./opentelemetry-lambda/*" -not -path "./ci/*" -not -name "layer-data.sh" -print)
    for file in ${files}; do
        # Run tests in their own context
        echo "Checking ${file} with shellcheck"
        shellcheck --enable all --external-sources "${file}"
    done

files=$(find . -name '*' -type 'f' -path "*/scripts/*" -not -path "*/combine/*" -not -path "*/opentelemetry-lambda/*" -print)
    for file in ${files}; do
        # Run tests in their own context
        echo "Checking script ${file} with shellcheck"
        shellcheck --enable all --external-sources --exclude SC2154 "${file}"
    done

files=$(find . -name 'layer-data.sh' -type 'f' -print)
    for file in ${files}; do
        # Run tests in their own context
        echo "Checking layer-data file: ${file} with shellcheck"
        shellcheck --enable all --external-sources --exclude SC2034 "${file}"
    done

files=$(find . -name '*.sh' -type 'f' -path "./ci/*" -print)
    for file in ${files}; do
        # Run tests in their own context
        echo "Checking ci: ${file} with shellcheck"
        shellcheck --enable all --external-sources --exclude SC2312 "${file}"
    done

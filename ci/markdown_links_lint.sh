#!/usr/bin/env bash

GREP="grep"

dist=$(uname -s)
if [[ "${dist}" == "Darwin" ]]; then
    GREP="ggrep"
fi

if ! command -v "${GREP}" ; then
    echo "${GREP} is missing from the system, please install it."
    exit 1
fi

# Get all markdown files
FILES=$(find . -type f -name '*.md' -not -path "./opentelemetry-lambda/*" -not -path "*/node_modules/*")

readonly FILES=${FILES}

RET_VAL=0

for file in ${FILES}; do
    if "${GREP}" -HnoP '\[[^\]]*\]\([^\)]*\)' "${file}" \
        | "${GREP}" 'github.com/sumologic/sumologic-otel-lambda' \
        | "${GREP}" -vP '(\/(blob|tree)\/(v\d+\.|[a-f0-9]{40}\/|release\-))' \
        | "${GREP}" -vP '\/releases\)'; then
    
        RET_VAL=1
    fi
done

exit "${RET_VAL}"

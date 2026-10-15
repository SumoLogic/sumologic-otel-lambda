#!/bin/bash

set -euo pipefail

: "${LANGUAGE:?LANGUAGE is required (java, nodejs, or python)}"
: "${VERSION:?VERSION is required (e.g. 1.41.0)}"
: "${OTEL_LAMBDA_TAG:?OTEL_LAMBDA_TAG is required (e.g. layer-python/0.19.0)}"

VERSION_DASHED="v${VERSION//./-}"
TAG="${LANGUAGE}-v${VERSION}"
RELEASE_BRANCH="release-${TAG}"
DATE="$(date +%Y-%m-%d)"

LAYER_DATA="${LANGUAGE}/layer-data.sh"
TEMPLATE="${LANGUAGE}/sample-apps/template.yaml"
VERSION_FILE="${LANGUAGE}/version.txt"
LANGUAGE_README="${LANGUAGE}/README.md"

cleanup() { find . -maxdepth 3 -name '*.bak' -delete; }
trap cleanup EXIT

OLD_VERSION_DASHED=$(grep '^VERSION=' "${LAYER_DATA}" | cut -d= -f2)
if [[ -z "${OLD_VERSION_DASHED}" ]]; then
  echo "ERROR: could not extract VERSION from ${LAYER_DATA}" >&2
  exit 1
fi

# --- Create changelog fragment (avoids CHANGELOG.md merge conflicts) ---

mkdir -p changelog
cat > "changelog/${TAG}.md" <<EOF
## [${TAG}]

### Released ${DATE}

### Changed

- TODO: fill in changelog

[${TAG}]: https://github.com/SumoLogic/sumologic-otel-lambda/releases/tag/${TAG}
EOF

# --- Update version.txt ---

printf 'current_version=%s\nupstream_release_tag=%s\n' \
  "${VERSION}" "${OTEL_LAMBDA_TAG}" > "${VERSION_FILE}"

# --- Update layer-data.sh ---

sed -i.bak "s|^VERSION=.*|VERSION=${VERSION_DASHED}|" "${LAYER_DATA}"

sed -i.bak \
  "s|tree/[^/]*/\{0,1\}${LANGUAGE}|tree/${RELEASE_BRANCH}/${LANGUAGE}|" \
  "${LAYER_DATA}"

# --- Update template.yaml ---

sed -i.bak "s|${OLD_VERSION_DASHED}|${VERSION_DASHED}|g" "${TEMPLATE}"

# --- Detect component versions from submodule ---

COLLECTOR_VERSION=$(grep "go.opentelemetry.io/collector/otelcol v" \
  opentelemetry-lambda/collector/go.mod | awk '{print $2}')
if [[ -z "${COLLECTOR_VERSION}" ]]; then
  echo "ERROR: could not extract COLLECTOR_VERSION from collector/go.mod" >&2
  exit 1
fi

case "${LANGUAGE}" in
  python)
    SDK_VERSION=$(grep "^opentelemetry-sdk==" \
      opentelemetry-lambda/python/src/otel/otel_sdk/requirements.txt \
      | cut -d= -f3)
    INSTRUMENTATION_VERSION=$(grep "^opentelemetry-distro==" \
      opentelemetry-lambda/python/src/otel/otel_sdk/requirements.txt \
      | cut -d= -f3)
    if [[ -z "${SDK_VERSION}" ]]; then
      echo "ERROR: could not extract opentelemetry-sdk version from requirements.txt" >&2
      exit 1
    fi
    if [[ -z "${INSTRUMENTATION_VERSION}" ]]; then
      echo "ERROR: could not extract opentelemetry-distro version from requirements.txt" >&2
      exit 1
    fi
    ;;
  nodejs)
    SDK_VERSION=v$(grep -A5 '"node_modules/@opentelemetry/sdk-trace-node"' \
      opentelemetry-lambda/nodejs/package-lock.json \
      | grep '"version"' | grep -o '[0-9][0-9.]*' | head -1)
    if [[ "${SDK_VERSION}" == "v" ]]; then
      echo "ERROR: could not extract @opentelemetry/sdk-trace-node version from package-lock.json" >&2
      exit 1
    fi
    ;;
  java)
    SDK_VERSION=$(grep 'opentelemetry-javaagent:' \
      opentelemetry-lambda/java/dependencyManagement/build.gradle.kts \
      | grep -o '[0-9][0-9.]*' | head -1)
    if [[ -z "${SDK_VERSION}" ]]; then
      echo "ERROR: could not extract opentelemetry-javaagent version from build.gradle.kts" >&2
      exit 1
    fi
    ;;
esac

# --- Update language README.md ---

python3 - "${LANGUAGE_README}" "${VERSION}" <<'PYEOF'
import re
import sys

readme_path = sys.argv[1]
version = sys.argv[2]

with open(readme_path) as f:
    content = f.read()

pattern = re.compile(
    r"^(# .*?)(?:unreleased version|v\d+\.\d+\.\d+)(.*)$",
    re.MULTILINE,
)
if not pattern.search(content):
    print(f"ERROR: release version not found in title of {readme_path}",
          file=sys.stderr)
    sys.exit(1)

content = pattern.sub(rf"\g<1>v{version}\g<2>", content, count=1)

with open(readme_path, "w") as f:
    f.write(content)
PYEOF

# --- Update root README.md ---

sed -i.bak \
  "s|release-${LANGUAGE}-v[0-9][0-9.]*/${LANGUAGE}|release-${LANGUAGE}-v${VERSION}/${LANGUAGE}|g" \
  README.md

case "${LANGUAGE}" in
  python)
    sed -i.bak "/Python layer/s|SDK \`v[^\`]*\`|SDK \`v${SDK_VERSION}\`|" README.md
    sed -i.bak "/Python layer/s|instrumentation \`v[^\`]*\`|instrumentation \`v${INSTRUMENTATION_VERSION}\`|" README.md
    sed -i.bak "/Python layer/s|Collector \`v[^\`]*\`|Collector \`${COLLECTOR_VERSION}\`|" README.md
    ;;
  nodejs)
    sed -i.bak "/NodeJS layer/s|SDK \`v[^\`]*\`|SDK \`${SDK_VERSION}\`|" README.md
    sed -i.bak "/NodeJS layer/s|Collector \`v[^\`]*\`|Collector \`${COLLECTOR_VERSION}\`|" README.md
    ;;
  java)
    sed -i.bak "/Java wrapper/s|Java \`v[^\`]*\`|Java \`v${SDK_VERSION}\`|" README.md
    sed -i.bak "/Java wrapper/s|Collector \`v[^\`]*\`|Collector \`${COLLECTOR_VERSION}\`|" README.md
    ;;
esac

echo "Release preparation complete for ${TAG}"

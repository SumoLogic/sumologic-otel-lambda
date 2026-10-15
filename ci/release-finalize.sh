#!/bin/bash

set -euo pipefail

: "${LANGUAGE:?LANGUAGE is required (java, nodejs, or python)}"
: "${VERSION:?VERSION is required (e.g. 1.41.0)}"

if [[ ! "${LANGUAGE}" =~ ^(java|nodejs|python)$ ]]; then
  echo "ERROR: Unsupported language: ${LANGUAGE}" >&2
  exit 1
fi
if [[ ! "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: Invalid version: ${VERSION}" >&2
  exit 1
fi

README="${LANGUAGE}/README.md"

python3 - "${README}" "${VERSION}" <<'PYEOF'
import re
import sys

readme_path = sys.argv[1]
version = sys.argv[2]

with open(readme_path) as f:
    content = f.read()

title_pattern = re.compile(
    r"^(# .*?)(?:unreleased version|v\d+\.\d+\.\d+)(.*)$",
    re.MULTILINE,
)
if not title_pattern.search(content):
    print(f"ERROR: release version not found in title of {readme_path}",
          file=sys.stderr)
    sys.exit(1)

content = title_pattern.sub(rf"\g<1>v{version}\g<2>", content, count=1)

with open(readme_path, "w") as f:
    f.write(content)

print(f"Updated {readme_path} title to v{version}")
PYEOF

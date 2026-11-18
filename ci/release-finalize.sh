#!/bin/bash

# Prepares <language>/README.md for the release branch:
# - sets the release version in the title
# - replaces the AMD64 and ARM64 layer ARN tables (when ARNS_FILE is set)
# - points the container links to the release tag
#
# ARNS_FILE is any text that contains the published layer ARNs, for example the
# ARN artifacts of the release build or the body of the GitHub release.

set -euo pipefail

: "${LANGUAGE:?LANGUAGE is required (java, nodejs, or python)}"
: "${VERSION:?VERSION is required (e.g. 1.41.0)}"
ARNS_FILE="${ARNS_FILE:-}"

if [[ ! "${LANGUAGE}" =~ ^(java|nodejs|python)$ ]]; then
  echo "ERROR: Unsupported language: ${LANGUAGE}" >&2
  exit 1
fi
if [[ ! "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: Invalid version: ${VERSION}" >&2
  exit 1
fi
if [[ -n "${ARNS_FILE}" && ! -f "${ARNS_FILE}" ]]; then
  echo "ERROR: ARNS_FILE ${ARNS_FILE} does not exist" >&2
  exit 1
fi

README="${LANGUAGE}/README.md"

python3 - "${README}" "${LANGUAGE}" "${VERSION}" "${ARNS_FILE}" <<'PYEOF'
import re
import sys

readme_path, language, version, arns_path = sys.argv[1:5]
tag = f"{language}-v{version}"

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

content = re.sub(
    rf"releases/download/{language}-v\d+\.\d+\.\d+/",
    f"releases/download/{tag}/",
    content,
)


def format_table(rows):
    header = ("Region", "ARN")
    widths = [max(len(r[i]) for r in [header, *rows]) for i in range(2)]
    lines = ["| " + " | ".join(c.ljust(w) for c, w in zip(header, widths)) + " |",
             "|" + "|".join("-" * (w + 2) for w in widths) + "|"]
    lines += ["| " + " | ".join(c.ljust(w) for c, w in zip(r, widths)) + " |"
              for r in rows]
    return "\n".join(lines) + "\n"


def replace_table(text, heading, rows):
    pattern = re.compile(
        rf"(^## {re.escape(heading)}\n\n)(?:\|.*\n)+",
        re.MULTILINE,
    )
    if not pattern.search(text):
        print(f"ERROR: table '{heading}' not found in {readme_path}",
              file=sys.stderr)
        sys.exit(1)
    return pattern.sub(lambda m: m.group(1) + format_table(rows), text, count=1)


if arns_path:
    with open(arns_path) as f:
        arns = sorted(set(re.findall(
            r"arn:aws:lambda:[a-z0-9-]+:\d+:layer:[A-Za-z0-9_-]+:\d+", f.read())))

    tables = {}
    for arch, name in (("x86_64", "AMD64"), ("arm64", "ARM64")):
        version_dashed = "v" + version.replace(".", "-")
        rows = [(arn.split(":")[3], arn) for arn in arns
                if f"-{arch}-{version_dashed}:" in arn]
        if not rows:
            print(f"ERROR: no {name} ARNs for {tag} in {arns_path}",
                  file=sys.stderr)
            sys.exit(1)
        tables[name] = sorted(rows)

    for name, rows in tables.items():
        content = replace_table(content, f"{name} Lambda Layers List", rows)
        print(f"Wrote {len(rows)} {name} layer ARNs")

with open(readme_path, "w") as f:
    f.write(content)

print(f"Updated {readme_path} for {tag}")
PYEOF

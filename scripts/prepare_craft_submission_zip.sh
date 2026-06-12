#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SOURCE_INDEX="${REPO_ROOT}/index.html"
DIST_DIR="${REPO_ROOT}/dist"
ZIP_PATH="${DIST_DIR}/craft-hand-project-report.zip"
STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/craft-hand-project-report.XXXXXX")"
trap 'rm -rf "${STAGING_DIR}"' EXIT

if ! command -v zip >/dev/null 2>&1; then
    echo "zip is required but was not found in PATH." >&2
    exit 1
fi

if [ ! -f "${SOURCE_INDEX}" ]; then
    echo "Missing source index.html: ${SOURCE_INDEX}" >&2
    exit 1
fi

rm -rf "${STAGING_DIR}"
mkdir -p "${STAGING_DIR}" "${DIST_DIR}"

cp "${SOURCE_INDEX}" "${STAGING_DIR}/index.html"

while IFS= read -r ref; do
    case "${ref}" in
        ""|"#"|data:*|http:*|https:*)
            continue
            ;;
        /*)
            echo "Absolute local path is not portable for submission: ${ref}" >&2
            exit 1
            ;;
    esac

    src="${REPO_ROOT}/${ref}"
    dst="${STAGING_DIR}/${ref}"
    if [ ! -f "${src}" ]; then
        echo "Missing referenced asset: ${ref}" >&2
        exit 1
    fi

    mkdir -p "$(dirname "${dst}")"
    cp "${src}" "${dst}"
done < <(perl -nE 'while (/(?:src|poster)="([^"]+)"/g) { say $1 }' "${SOURCE_INDEX}" | sort -u)

rm -f "${ZIP_PATH}"
(
    cd "${STAGING_DIR}"
    COPYFILE_DISABLE=1 zip -q -r -X "${ZIP_PATH}" .
)

echo "Created ${ZIP_PATH}"
echo "Verify with:"
echo "  rm -rf /tmp/craft-hand-project-report-check"
echo "  unzip -q ${ZIP_PATH} -d /tmp/craft-hand-project-report-check"
echo "  open /tmp/craft-hand-project-report-check/index.html"

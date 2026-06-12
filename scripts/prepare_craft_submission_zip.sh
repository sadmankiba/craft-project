#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SOURCE_PAGE="${REPO_ROOT}/note/craft-hand-project.html"
SUBMISSION_DIR="${REPO_ROOT}/submission/craft-hand-project"
DIST_DIR="${REPO_ROOT}/dist"
ZIP_PATH="${DIST_DIR}/craft-hand-project-report.zip"

if ! command -v zip >/dev/null 2>&1; then
    echo "zip is required but was not found in PATH." >&2
    exit 1
fi

if [ ! -f "${SOURCE_PAGE}" ]; then
    echo "Missing source page: ${SOURCE_PAGE}" >&2
    exit 1
fi

rm -rf "${SUBMISSION_DIR}"
mkdir -p \
    "${SUBMISSION_DIR}/files/craft-hand-project" \
    "${SUBMISSION_DIR}/img/note/craft-hand-project" \
    "${DIST_DIR}"

perl -0pe '
  s@\A---\ntitle: CRAFT Hand Project Report\n---\n@@;
  s@\{% include head.html %\}@<head>\n    <meta charset="utf-8">\n    <meta name="viewport" content="width=device-width, initial-scale=1">\n    <title>CRAFT Hand Project Report</title>\n    <link rel="icon" href="data:,">\n</head>@g;
  s@\s*\{% include navigation.html %\}\n@@g;
  s@\s*\{% include tail-scripts.html %\}\n\s*\{% include footer.html %\}\n@@g;
  s@<body>\s*<style>@<body>\n    <style>@;
  s@<style>@<style>\n        body {\n            margin: 0;\n            color: #26323f;\n            background: #fff;\n            font-family: Arial, Helvetica, sans-serif;\n        }\n\n        .container {\n            box-sizing: border-box;\n            margin: 0 auto;\n            padding: 2.5rem 1rem 3rem;\n            width: 100%;\n        }\n\n        code {\n            font-family: "Courier New", Courier, monospace;\n        }@;
  s@(src|poster)="/@$1="@g;
' "${SOURCE_PAGE}" > "${SUBMISSION_DIR}/index.html"

cp -R "${REPO_ROOT}/files/craft-hand-project/." "${SUBMISSION_DIR}/files/craft-hand-project/"
cp -R "${REPO_ROOT}/img/note/craft-hand-project/." "${SUBMISSION_DIR}/img/note/craft-hand-project/"

missing=0
while IFS= read -r asset; do
    case "${asset}" in
        http:*|https:*|"#"|"")
            continue
            ;;
    esac
    if [ ! -f "${SUBMISSION_DIR}/${asset}" ]; then
        echo "Missing referenced asset: ${asset}" >&2
        missing=1
    fi
done < <(perl -nE 'while (/(?:src|poster)="([^"]+)"/g) { say $1 }' "${SUBMISSION_DIR}/index.html")

if [ "${missing}" -ne 0 ]; then
    exit 1
fi

rm -f "${ZIP_PATH}"
(
    cd "${SUBMISSION_DIR}"
    COPYFILE_DISABLE=1 zip -q -r -X "${ZIP_PATH}" .
)

echo "Created ${ZIP_PATH}"
echo "Verify with:"
echo "  rm -rf /tmp/craft-hand-project-report-check"
echo "  unzip -q ${ZIP_PATH} -d /tmp/craft-hand-project-report-check"
echo "  open /tmp/craft-hand-project-report-check/index.html"

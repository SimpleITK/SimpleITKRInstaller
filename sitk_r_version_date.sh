#!/usr/bin/env sh
# sitk_r_version_date.sh - Update the Version and Date fields in DESCRIPTION
# based on the SITK_TARGET field.
#
# Run this script manually after changing the SITK_TARGET field in DESCRIPTION:
#   sh sitk_r_version_date.sh
#
# The script reads SITK_TARGET and the SimpleITK repository URL from DESCRIPTION,
# does a minimal blobless clone to a temporary directory to resolve the tag/commit,
# derives an R-compatible Version (MAJOR.MINOR.PATCH[.9000]) and the commit Date,
# then writes both back into DESCRIPTION.
#
# R version convention: MAJOR.MINOR.PATCH[.9000] where .9000 indicates a
# development/pre-release build per https://r-pkgs.org/lifecycle.html#dev-version.
# SimpleITK tags with non-numeric suffixes (rc, a, b, b0x, etc.) and non-numeric
# tags (va01, latest) are mapped to nearest numeric prefix + .9000 or 0.0.0.9000.
#
# Requires: git, sed, awk

set -e

PKGBASED="$(cd "$(dirname "$0")" && pwd)"
DESCRIPTION="${PKGBASED}/DESCRIPTION"

if [ ! -f "${DESCRIPTION}" ]; then
    echo "ERROR: DESCRIPTION not found at ${DESCRIPTION}" >&2
    exit 1
fi

SITK_TARGET=$(grep '^SITK_TARGET:' "${DESCRIPTION}" | awk '{print $2}')
SITK_GIT=$(grep '^URL:' "${DESCRIPTION}" | sed 's/URL: *//' | cut -d',' -f1 | tr -d ' ')

if [ -z "${SITK_TARGET}" ]; then
    echo "ERROR: SITK_TARGET field not found in DESCRIPTION" >&2
    exit 1
fi
if [ -z "${SITK_GIT}" ]; then
    echo "ERROR: URL field not found in DESCRIPTION" >&2
    exit 1
fi

echo "SITK_TARGET: ${SITK_TARGET}"
echo "Cloning ${SITK_GIT} (blobless) ..."

TMPDIR=$(mktemp -d)
trap 'rm -rf "${TMPDIR}"' EXIT

git clone --filter=blob:none --no-checkout "${SITK_GIT}" "${TMPDIR}/SimpleITK"
cd "${TMPDIR}/SimpleITK"
git fetch --tags
git checkout "${SITK_TARGET}"

SITK_SRC="${TMPDIR}/SimpleITK"

# Derive R-compatible Version from the checked-out commit/tag.
ACTUAL_TAG=$(git -C "${SITK_SRC}" describe --tags --exact-match 2>/dev/null || true)
if [ -n "${ACTUAL_TAG}" ]; then
    # Exact tag: strip leading 'v', then strip any non-numeric pre-release suffix.
    # e.g. v2.5.0rc1->2.5.0.9000, v3.0.0a1->3.0.0.9000, v0.3.0b->0.3.0.9000, v2.5.3->2.5.3
    RAW=$(echo "${ACTUAL_TAG}" | sed 's/^v//')
    STRIPPED=$(echo "${RAW}" | sed 's/\([0-9][0-9]*\(\.[0-9][0-9]*\)*\)[^0-9.].*/\1/')
    if [ -z "${STRIPPED}" ] || ! echo "${STRIPPED}" | grep -qE '^[0-9]+(\.[0-9]+)*$'; then
        R_VERSION="0.0.0.9000"
    elif [ "${RAW}" = "${STRIPPED}" ]; then
        R_VERSION="${STRIPPED}"
    else
        R_VERSION="${STRIPPED}.9000"
    fi
else
    # Not on an exact tag.
    # First preference: a future tag (HEAD is an ancestor of the tag) — building toward it.
    # git describe --contains output is "TAG~N" or "TAG^0~N"; strip from first ~ or ^.
    FUTURE_TAG=$(git -C "${SITK_SRC}" describe --tags --contains HEAD 2>/dev/null | head -n 1 | sed 's/[~^].*//' || true)
    if [ -n "${FUTURE_TAG}" ]; then
        BASE=$(echo "${FUTURE_TAG}" | sed 's/^v//')
        STRIPPED=$(echo "${BASE}" | sed 's/\([0-9][0-9]*\(\.[0-9][0-9]*\)*\)[^0-9.].*/\1/')
        if [ -n "${STRIPPED}" ] && echo "${STRIPPED}" | grep -qE '^[0-9]+(\.[0-9]+)*$'; then
            R_VERSION="${STRIPPED}.9000"
        else
            R_VERSION="0.0.0.9000"
        fi
    else
        # Second preference: nearest ancestor tag.
        BASE=$(git -C "${SITK_SRC}" describe --tags 2>/dev/null | sed 's/-[0-9]*-g[0-9a-f]*//' | sed 's/^v//' || true)
        if [ -n "${BASE}" ]; then
            STRIPPED=$(echo "${BASE}" | sed 's/\([0-9][0-9]*\(\.[0-9][0-9]*\)*\)[^0-9.].*/\1/')
            if [ -n "${STRIPPED}" ] && echo "${STRIPPED}" | grep -qE '^[0-9]+(\.[0-9]+)*$'; then
                R_VERSION="${STRIPPED}.9000"
            else
                R_VERSION="0.0.0.9000"
            fi
        else
            R_VERSION="0.0.0.9000"
        fi
    fi
fi

COMMIT_DATE=$(git -C "${SITK_SRC}" log -1 --format=%cs 2>/dev/null || true)
if [ -z "${COMMIT_DATE}" ]; then
    COMMIT_DATE=$(date +%Y-%m-%d)
fi

echo "Setting Version to ${R_VERSION}"
echo "Setting Date to ${COMMIT_DATE}"
tmp=$(mktemp)
sed "s/^Version:.*/Version: ${R_VERSION}/" "${DESCRIPTION}" > "${tmp}" && mv "${tmp}" "${DESCRIPTION}"
tmp=$(mktemp)
sed "s/^Date:.*/Date: ${COMMIT_DATE}/" "${DESCRIPTION}" > "${tmp}" && mv "${tmp}" "${DESCRIPTION}"
echo "Done. DESCRIPTION updated."

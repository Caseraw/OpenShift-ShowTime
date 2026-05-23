#!/usr/bin/env bash
set -euo pipefail

REGISTRY="${REGISTRY:-quay.io/rh-ee-kamirsar/2-tier-to-do-app}"
PUSH="${PUSH:-false}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

if [[ -z "${VERSION:-}" ]]; then
  FILE_VERSION="$(awk '/^version:/ { gsub(/"/, "", $2); print $2 }' "${ROOT}/component.yaml")"
  VERSION="$(resolve_next_version "${REGISTRY}" "${FILE_VERSION}")"
  UPDATE_MANIFESTS="${UPDATE_MANIFESTS:-true}"
  if [[ "${UPDATE_MANIFESTS}" == "true" ]]; then
    echo "Updating manifests to version ${VERSION} ..."
    update_manifest_version "${ROOT}" "${VERSION}"
  fi
else
  echo "Using VERSION=${VERSION} (skip registry resolution)."
fi

export VERSION
export REGISTRY
export PUSH=true
export UPDATE_MANIFESTS=false

"${SCRIPT_DIR}/build.sh"

echo
echo "Published version: ${VERSION}"
echo "Deploy with:"
echo "  oc apply -k ${ROOT}/kustomize/postgresql/"
echo "  oc apply -k ${ROOT}/kustomize/frontend/"

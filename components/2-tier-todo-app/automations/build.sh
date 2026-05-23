#!/usr/bin/env bash
set -euo pipefail

REGISTRY="${REGISTRY:-quay.io/rh-ee-kamirsar/2-tier-to-do-app}"
PUSH="${PUSH:-false}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${VERSION:-$(awk '/^version:/ { gsub(/"/, "", $2); print $2 }' "${ROOT}/component.yaml")}"
VERSION="${VERSION:-0.1.0}"

build_image() {
  local name="$1"
  local context="$2"
  local versioned_tag="${name}-${VERSION}"
  local latest_tag="${name}-latest"
  local versioned_image="${REGISTRY}:${versioned_tag}"
  local latest_image="${REGISTRY}:${latest_tag}"

  echo "Building ${versioned_image} ..."
  podman build -t "${versioned_image}" -f "${context}/Containerfile" "${context}"
  podman tag "${versioned_image}" "${latest_image}"

  if [[ "${PUSH}" == "true" ]]; then
    echo "Pushing ${versioned_image} and ${latest_image} ..."
    podman push "${versioned_image}"
    podman push "${latest_image}"
  fi
}

build_image frontend "${ROOT}/src/frontend"
build_image postgresql "${ROOT}/src/postgresql"

echo "Done."
echo "  ${REGISTRY}:frontend-${VERSION}"
echo "  ${REGISTRY}:frontend-latest"
echo "  ${REGISTRY}:postgresql-${VERSION}"
echo "  ${REGISTRY}:postgresql-latest"

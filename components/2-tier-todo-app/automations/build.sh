#!/usr/bin/env bash
set -euo pipefail

REGISTRY="${REGISTRY:-quay.io/rh-ee-kamirsar/2-tier-to-do-app}"
TAG="${TAG:-latest}"
PUSH="${PUSH:-false}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

build_image() {
  local name="$1"
  local context="$2"
  local image="${REGISTRY}:${name}-${TAG}"

  echo "Building ${image} ..."
  podman build -t "${image}" -f "${context}/Containerfile" "${context}"
  podman tag "${image}" "${REGISTRY}:${name}"

  if [[ "${PUSH}" == "true" ]]; then
    echo "Pushing ${image} and ${REGISTRY}:${name} ..."
    podman push "${image}"
    podman push "${REGISTRY}:${name}"
  fi
}

build_image frontend "${ROOT}/src/frontend"
build_image postgresql "${ROOT}/src/postgresql"

echo "Done."
echo "  ${REGISTRY}:frontend-${TAG}"
echo "  ${REGISTRY}:frontend"
echo "  ${REGISTRY}:postgresql-${TAG}"
echo "  ${REGISTRY}:postgresql"

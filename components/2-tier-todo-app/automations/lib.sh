#!/usr/bin/env bash
# Shared helpers for 2-tier-todo-app image build automations.

registry_repo_path() {
  local registry="${1:?registry required}"
  registry="${registry#quay.io/}"
  registry="${registry#docker://}"
  registry="${registry#https://quay.io/}"
  echo "${registry%%/*}/${registry#*/}"
}

list_registry_tags() {
  local registry="${1:?registry required}"
  local repo_path
  repo_path="$(registry_repo_path "${registry}")"
  local namespace="${repo_path%%/*}"
  local repo="${repo_path#*/}"

  if command -v skopeo >/dev/null 2>&1; then
    if tags_json="$(skopeo list-tags "docker://${registry}" 2>/dev/null)"; then
      if command -v jq >/dev/null 2>&1; then
        echo "${tags_json}" | jq -r '.Tags[]?' 2>/dev/null
        return 0
      fi
      echo "${tags_json}" | grep -o '"Tags":\[[^]]*\]' | tr ',' '\n' | sed -n 's/.*"\([^"]*\)".*/\1/p'
      return 0
    fi
  fi

  local page=1
  local tag_names=""
  while :; do
    local response
  response="$(curl -fsSL "https://quay.io/api/v1/repository/${namespace}/${repo}/tag/?limit=100&page=${page}&onlyActiveTags=true" 2>/dev/null)" || break
    if command -v jq >/dev/null 2>&1; then
      local page_tags
      page_tags="$(echo "${response}" | jq -r '.tags[]?.name // empty' 2>/dev/null)"
      [[ -n "${page_tags}" ]] || break
      tag_names+=$'\n'"${page_tags}"
      local has_more
      has_more="$(echo "${response}" | jq -r '.has_additional // false' 2>/dev/null)"
      [[ "${has_more}" == "true" ]] || break
    else
      break
    fi
    page=$((page + 1))
  done

  if [[ -n "${tag_names}" ]]; then
    echo "${tag_names#"$'\n'"}"
  fi
}

semver_from_image_tag() {
  local tag="$1"
  if [[ "${tag}" =~ ^(frontend|postgresql)-([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
    echo "${BASH_REMATCH[2]}"
  fi
}

max_semver() {
  sort -V | tail -n 1
}

bump_patch_version() {
  local version="$1"
  local major minor patch
  IFS=. read -r major minor patch <<< "${version}"
  echo "${major}.${minor}.$((patch + 1))"
}

version_in_registry() {
  local registry="$1"
  local version="$2"
  local tags
  tags="$(list_registry_tags "${registry}")"
  grep -qx "frontend-${version}" <<< "${tags}" || grep -qx "postgresql-${version}" <<< "${tags}"
}

resolve_next_version() {
  local registry="$1"
  local file_version="$2"
  local tags semver collected="" tag

  tags="$(list_registry_tags "${registry}" || true)"
  while IFS= read -r tag; do
    [[ -n "${tag}" ]] || continue
    semver="$(semver_from_image_tag "${tag}")"
    [[ -n "${semver}" ]] || continue
    collected+="${semver}"$'\n'
  done <<< "${tags}"

  [[ -n "${file_version}" ]] && collected+="${file_version}"$'\n'

  local base_version
  if [[ -z "${collected//[$'\n']/}" ]]; then
    base_version="${file_version:-0.1.0}"
  else
    base_version="$(printf '%s\n' "${collected}" | sed '/^$/d' | max_semver)"
  fi

  if version_in_registry "${registry}" "${base_version}"; then
    bump_patch_version "${base_version}"
  else
    echo "${base_version}"
  fi
}

update_manifest_version() {
  local root="$1"
  local version="$2"

  sed -i.bak "s/^version: \".*\"/version: \"${version}\"/" "${root}/component.yaml"

  sed -i.bak "s/newTag: frontend-.*/newTag: frontend-${version}/" \
    "${root}/kustomize/frontend/kustomization.yaml"
  sed -i.bak "s/newTag: postgresql-.*/newTag: postgresql-${version}/" \
    "${root}/kustomize/postgresql/kustomization.yaml"

  sed -i.bak "s|:frontend-[0-9][0-9.]*|:frontend-${version}|" \
    "${root}/kustomize/frontend/deployment.yaml"
  sed -i.bak "s|:postgresql-[0-9][0-9.]*|:postgresql-${version}|" \
    "${root}/kustomize/postgresql/deployment.yaml"

  rm -f "${root}/component.yaml.bak" \
    "${root}/kustomize/frontend/kustomization.yaml.bak" \
    "${root}/kustomize/postgresql/kustomization.yaml.bak" \
    "${root}/kustomize/frontend/deployment.yaml.bak" \
    "${root}/kustomize/postgresql/deployment.yaml.bak"
}

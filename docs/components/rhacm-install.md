# rhacm-install

**Component name:** `rhacm-install`  
**Repository path:** [`components/rhacm-install/`](https://github.com/Caseraw/OpenShift-ShowTime/tree/main/components/rhacm-install)

## Purpose

Install Red Hat Advanced Cluster Management on an OpenShift **hub** cluster using Kustomize:

- `kustomize/operator/` — operator install manifests
- `kustomize/platform/` — MultiClusterHub and related platform objects

## Used by scenarios

- [hub-spoke-acm](../scenarios/hub-spoke-acm.md)

## Authoring note

Manifest directories are scaffolded with empty `resources` lists. Add your existing Kustomize YAML files and reference them in each subdirectory's `kustomization.yaml`.

# RHACM Kustomize

Place your manifests in the subdirectories below. The root `kustomization.yaml` composes both layers in order: **operator** first, then **platform**.

| Directory | Purpose |
|-----------|---------|
| `operator/` | RHACM operator install (OperatorGroup, Subscription, etc.) |
| `platform/` | MultiClusterHub and other objects after the operator is available |

After adding YAML files, list them in the respective `kustomization.yaml` `resources` entries.

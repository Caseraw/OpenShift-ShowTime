# Red Hat Advanced Cluster Management — Install

Installs **Red Hat Advanced Cluster Management (RHACM)** on a designated OpenShift **hub** cluster using Kustomize.

## Responsibility

This component owns only hub-side RHACM installation:

1. **Operator** — OperatorGroup, Subscription, and related operator prerequisites.
2. **Platform** — MultiClusterHub and other post-operator objects required for a functional management plane.

Spoke cluster import and hub-spoke topology are covered by the [hub-spoke-acm](../../scenarios/hub-spoke-acm/) scenario.

## Prerequisites

- OpenShift 4.x cluster designated as the **hub**
- Cluster-admin access (`oc login` to the hub)
- Sufficient cluster resources for RHACM (see [RHACM requirements](https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/))
- Any pull secrets or offline mirroring credentials in `byo/Credentials/` (not committed)

## Kustomize layout

```
kustomize/
├── kustomization.yaml    # Aggregates operator + platform
├── operator/               # RHACM operator install (your manifests go here)
└── platform/               # MultiClusterHub and related objects
```

Add your existing Kustomize manifests under `operator/` and `platform/`. Each subdirectory has its own `kustomization.yaml` that lists your resources.

## Usage

From the repository root (or this component directory):

```bash
# Preview
kustomize build components/rhacm-install/kustomize

# Apply to the hub cluster
kustomize build components/rhacm-install/kustomize | oc apply -f -
```

Wait until the MultiClusterHub (or equivalent) reports healthy before proceeding with spoke import in the scenario demo.

## Outputs

- RHACM operator installed on the hub
- Management plane ready to register and manage spoke OpenShift clusters

## BYO

| Material | Location |
|----------|----------|
| Pull secrets, kubeconfigs | `byo/Credentials/` |
| Environment-specific overrides | `byo/Other/` (optional Kustomize overlay, local only) |

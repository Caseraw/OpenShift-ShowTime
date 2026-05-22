# Basic hub and spoke with Red Hat Advanced Cluster Management

## User story

**As a** platform engineer responsible for multiple OpenShift clusters,  
**I want** a central **hub** cluster running Red Hat Advanced Cluster Management (RHACM) and one or more **spoke** clusters under that management plane,  
**So that** I can govern, observe, and operate the fleet from a single control point instead of logging into each cluster separately.

## Narrative

Many teams start with a single OpenShift cluster, then add clusters for isolation (dev/test/prod), geography, or tenant boundaries. Without a management layer, every cluster is operated independently—policies, access, and application placement diverge over time.

A **hub-and-spoke** model addresses this:

- The **hub** hosts RHACM and is the administrative anchor.
- **Spokes** are standard OpenShift clusters enrolled into RHACM; they remain workloads environments while policy and multicluster operations flow from the hub.

This scenario establishes that foundation: install RHACM on the hub, bring the management plane to a ready state, then import spokes so they appear as managed clusters in the RHACM console.

## Components

| Order | Component | Role |
|-------|-----------|------|
| 1 | [rhacm-install](../../components/rhacm-install/) | Install RHACM operator and platform objects on the **hub** cluster |

Future components (not part of this scenario yet) may cover spoke bootstrap, placement, governance policies, or application delivery.

## Prerequisites

- One OpenShift cluster designated as the **hub**
- One or more OpenShift clusters designated as **spokes** (can be added after the hub is ready)
- Hub cluster meets [RHACM sizing and version requirements](https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/)
- `oc` logged in to the hub with cluster-admin credentials
- RHACM install manifests added under `components/rhacm-install/kustomize/` (operator, then platform)

## Success criteria

- RHACM operator is installed and healthy on the hub
- MultiClusterHub (or equivalent platform resource) reports a ready management plane
- At least one spoke cluster is imported and shows **Available** in RHACM

## BYO

| Item | Location |
|------|----------|
| Hub and spoke kubeconfigs | `byo/Credentials/` |
| Import tokens / cluster join secrets | `byo/Credentials/` |
| Local Kustomize overlays | `byo/Other/` |

## Demo

Step-by-step instructions: [demo/README.md](demo/README.md).

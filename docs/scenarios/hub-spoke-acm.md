# Hub and spoke with RHACM

**Scenario ID:** `hub-spoke-acm`  
**Repository path:** [`scenarios/hub-spoke-acm/`](https://github.com/Caseraw/OpenShift-ShowTime/tree/main/scenarios/hub-spoke-acm)

## Summary

A platform engineer stands up a **hub** OpenShift cluster with Red Hat Advanced Cluster Management (RHACM), then enrolls one or more **spoke** OpenShift clusters for centralized governance and operations.

## Components used

| Component | Purpose |
|-----------|---------|
| [rhacm-install](https://github.com/Caseraw/OpenShift-ShowTime/tree/main/components/rhacm-install) | Kustomize-based RHACM operator and platform install on the hub |

## Documentation in the repo

- [Scenario README and user story](https://github.com/Caseraw/OpenShift-ShowTime/blob/main/scenarios/hub-spoke-acm/README.md)
- [Demo steps](https://github.com/Caseraw/OpenShift-ShowTime/blob/main/scenarios/hub-spoke-acm/demo/README.md)
- [RHACM install component](https://github.com/Caseraw/OpenShift-ShowTime/blob/main/components/rhacm-install/README.md)

Add your Kustomize manifests under `components/rhacm-install/kustomize/operator/` and `components/rhacm-install/kustomize/platform/` before running the demo.

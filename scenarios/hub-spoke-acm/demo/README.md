# Demo — Hub and spoke with RHACM

Run this demo from the dev container (or any host with `oc` and `kustomize`) after adding your Kustomize manifests to `components/rhacm-install/kustomize/`.

## 1. Prepare the hub

```bash
oc login --kubeconfig="$BYO_KUBECONFIG_HUB"   # or your hub login flow
oc whoami --show-server
```

Store hub (and later spoke) kubeconfigs under `byo/Credentials/` — see [BYO](../../../byo/README.md).

## 2. Install RHACM on the hub

```bash
kustomize build ../../../components/rhacm-install/kustomize | oc apply -f -
```

Monitor operator and platform readiness:

```bash
oc get multiclusterhub -n open-cluster-management -w
oc get pods -n open-cluster-management
```

Adjust namespace names if your manifests differ.

## 3. Access the RHACM console

Open the RHACM console route on the hub (URL depends on your OpenShift version and RHACM release):

```bash
oc get route -n open-cluster-management | grep console
```

## 4. Import a spoke cluster

For each spoke OpenShift cluster:

1. Ensure network connectivity from hub to spoke API (and any firewall rules your environment requires).
2. In the RHACM console, use **Infrastructure → Clusters → Import cluster** (or equivalent for your RHACM version).
3. Apply the generated import manifest on the **spoke** cluster, or use the `oc` commands RHACM provides.
4. Confirm the cluster reaches **Available** in the RHACM UI.

```bash
oc login --kubeconfig="$BYO_KUBECONFIG_SPOKE"   # spoke cluster
# Apply RHACM-provided import resources here
```

## 5. Validate the fleet view

- Hub shows RHACM control plane healthy
- Each imported spoke appears under managed clusters
- Basic policy or observability features can be explored from the hub (optional stretch goals)

## Troubleshooting

- **Operator not subscribed** — verify `operator/` manifests and OpenShift OperatorHub catalog sources on the hub.
- **MultiClusterHub pending** — check RHACM operator pod logs and hub cluster resources.
- **Spoke import stuck** — verify kubeconfig/API reachability and that import secrets were applied on the spoke.

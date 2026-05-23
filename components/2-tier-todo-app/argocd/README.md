# Argo CD — 2-tier To Do app

Two **Application** resources deploy the hybrid 2-tier sample:

| Application | Kustomize path | Target cluster | Workload |
|-------------|----------------|----------------|----------|
| `todo-postgresql` | `kustomize/postgresql/` | on-prem OpenShift | PostgreSQL backend |
| `todo-frontend` | `kustomize/frontend/` | ROSA | Flask frontend + Route |

Both sync to the `todo-app` namespace on their respective cluster.

## Prerequisites

1. **Argo CD** (or OpenShift GitOps) on a management/hub cluster with access to on-prem and ROSA.
2. **Cluster secrets** registered in Argo CD whose names match `spec.destination.name`:
   - `on-prem` — datacenter OpenShift cluster
   - `rosa` — public-cloud ROSA cluster  
   Patch `destination.name` in the Application manifests (or via `byo/Other/`) if your Argo CD uses different cluster names.
3. **Container images** pushed to Quay (`automations/build-push.sh`).
4. **Secrets** — replace placeholder passwords in Kustomize secrets, or overlay from `byo/` before syncing.
5. **Hybrid DNS** — set `DB_HOST` in `kustomize/frontend/configmap.yaml` so ROSA can reach on-prem PostgreSQL.

## Register the Applications

From the repository root, on the cluster where Argo CD runs:

```bash
oc apply -k components/2-tier-todo-app/argocd/
```

If Argo CD uses the `argocd` namespace instead of `openshift-gitops`, patch the kustomization namespace or apply manually:

```bash
oc -n argocd apply -f components/2-tier-todo-app/argocd/postgresql-application.yaml
oc -n argocd apply -f components/2-tier-todo-app/argocd/frontend-application.yaml
```

## Sync order

1. **todo-postgresql** — database and seed data must exist first.
2. **todo-frontend** — after PostgreSQL is healthy and `DB_HOST` is reachable from ROSA.

Watch sync status:

```bash
oc -n openshift-gitops get applications todo-postgresql todo-frontend
```

## Customize

| Setting | Location |
|---------|----------|
| Git branch / tag | `spec.source.targetRevision` |
| Cluster names | `spec.destination.name` |
| Argo CD project | `spec.project` |
| Auto-sync | `spec.syncPolicy.automated` |

For environment-specific overrides, keep patches under `byo/Other/` and point Applications at a fork or overlay branch — do not commit real credentials.

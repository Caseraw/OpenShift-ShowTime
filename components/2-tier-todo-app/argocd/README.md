# Argo CD — 2-tier To Do app

Two **Application** resources deploy the hybrid 2-tier sample:

| Application | Kustomize path | Destination namespace | Workload |
|-------------|----------------|----------------------|----------|
| `todo-postgresql` | `kustomize/postgresql/` | `todo-postgresql` | PostgreSQL backend |
| `todo-frontend` | `kustomize/frontend/` | `todo-frontend` | Flask frontend + Route |

Each Application is labeled `app.kubernetes.io/name` with its resource name.

## Prerequisites

1. **Argo CD** (or OpenShift GitOps) with the target cluster registered (for example `in-cluster`).
2. **Container images** pushed to Quay (`automations/build-push.sh`).
3. **Secrets** — replace placeholder passwords in Kustomize secrets, or overlay from `byo/`.
4. **Hybrid DNS** — set `DB_HOST` in `kustomize/frontend/configmap.yaml` so the `todo-frontend` namespace can reach `todo-postgresql` (default: `todo-postgresql.todo-postgresql.svc.cluster.local`).

## Register the Applications

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
2. **todo-frontend** — after PostgreSQL is healthy and `DB_HOST` is reachable.

```bash
oc -n openshift-gitops get applications todo-postgresql todo-frontend
```

## Customize

| Setting | Location |
|---------|----------|
| Git branch / tag | `spec.source.targetRevision` |
| Destination cluster | `spec.destination.name` |
| Destination namespace | `spec.destination.namespace` (`todo-postgresql` / `todo-frontend`) |
| Argo CD project | `spec.project` |

# Kustomize — 2-tier To Do app

Deploy **todo-postgresql** and **todo-frontend** to different clusters:

| Overlay | Namespace | Path |
|---------|-----------|------|
| PostgreSQL backend | `todo-postgresql` | `postgresql/` |
| Frontend | `todo-frontend` | `frontend/` |

All resources use `app.kubernetes.io/name: todo-postgresql` or `app.kubernetes.io/name: todo-frontend`.

## Before you apply

1. Create namespaces on each cluster: `oc new-project todo-postgresql` and/or `oc new-project todo-frontend` (or rely on Argo CD `CreateNamespace=true`).
2. Replace placeholder passwords in both `secret.yaml` files (keep them in sync).
3. Add a Quay pull secret if needed in the target namespace.
4. On ROSA, confirm `frontend/configmap.yaml` `DB_HOST` resolves to the on-prem `todo-postgresql` Service.

Image tags follow `{image}-{version}` on `quay.io/rh-ee-kamirsar/2-tier-to-do-app`. Kustomize `images.newTag` in each overlay sets the deployed version (currently `0.1.0`).

## On-prem — todo-postgresql

```bash
oc login <on-prem-api>
oc apply -k components/2-tier-todo-app/kustomize/postgresql/
oc -n todo-postgresql wait --for=condition=available deployment/todo-postgresql --timeout=300s
```

## ROSA — todo-frontend

Set `DB_HOST` in `frontend/configmap.yaml` — default `todo-postgresql.todo-postgresql.svc.cluster.local` for cross-namespace access when hybrid DNS exposes the backend Service.

```bash
oc login <rosa-api>
oc apply -k components/2-tier-todo-app/kustomize/frontend/
oc -n todo-frontend wait --for=condition=available deployment/todo-frontend --timeout=300s
oc -n todo-frontend get route todo-frontend -o jsonpath='https://{.spec.host}{"\n"}'
```

## Verify

```bash
curl -sk "$(oc -n todo-frontend get route todo-frontend -o jsonpath='https://{.spec.host}')/ready"
curl -sk "$(oc -n todo-frontend get route todo-frontend -o jsonpath='https://{.spec.host}')/api/todos"
```

# Kustomize — 2-tier To Do app

Deploy **postgresql** and **frontend** to different clusters. Both overlays target the `todo-app` namespace.

| Overlay | Cluster | Path |
|---------|---------|------|
| PostgreSQL (backend) | OpenShift on-prem | `postgresql/` |
| Frontend | ROSA (public cloud) | `frontend/` |

## Before you apply

1. Create the namespace on each cluster: `oc new-project todo-app`
2. Replace placeholder passwords in both `secret.yaml` files (keep them in sync).
3. Add a Quay pull secret if the cluster cannot pull public images:  
   `oc -n todo-app create secret docker-registry quay-pull --docker-server=quay.io ...`  
   then patch the default ServiceAccount or Deployments.
4. On ROSA, set `frontend/configmap.yaml` `DB_HOST` to a hostname the frontend pod can resolve (see component README).

Image tags follow `{image}-{version}` on `quay.io/rh-ee-kamirsar/2-tier-to-do-app`. Kustomize `images.newTag` in each overlay sets the deployed version (currently `0.1.0`).

## On-prem — PostgreSQL

```bash
oc login <on-prem-api>
oc apply -k components/2-tier-todo-app/kustomize/postgresql/
oc -n todo-app wait --for=condition=available deployment/todo-postgresql --timeout=300s
```

Notes:

- Uses `strategy: Recreate` so the single-replica Deployment can safely reuse the ReadWriteOnce PVC.
- Sets `fsGroup: 999` and `PGDATA` under a subdirectory for OpenShift restricted SCC compatibility.
- Seeds five household demo tasks on a **new** PVC only.

## ROSA — Frontend

Configure how the frontend reaches PostgreSQL (possibly on another OpenShift cluster):

1. Set `DB_HOST` in `frontend/configmap.yaml` — commonly `todo-postgresql.todo-app.svc.cluster.local` when hybrid DNS exposes the on-prem Service.
2. Match `DB_PASSWORD` in `frontend/secret.yaml` with the PostgreSQL secret.
3. Optionally set `DATABASE_URL` in a Secret instead of the individual `DB_*` variables.

```bash
oc login <rosa-api>
oc apply -k components/2-tier-todo-app/kustomize/frontend/
oc -n todo-app wait --for=condition=available deployment/todo-frontend --timeout=300s
oc -n todo-app get route todo-frontend -o jsonpath='https://{.spec.host}{"\n"}'
```

The Route uses edge TLS and redirects HTTP to HTTPS. Readiness uses `/ready` and waits until PostgreSQL is reachable.

## Verify

```bash
# On ROSA
curl -sk "$(oc -n todo-app get route todo-frontend -o jsonpath='https://{.spec.host}')/ready"
curl -sk "$(oc -n todo-app get route todo-frontend -o jsonpath='https://{.spec.host}')/api/todos"
```

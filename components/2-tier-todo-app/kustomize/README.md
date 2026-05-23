# Kustomize — 2-tier To Do app

Deploy **postgresql** and **frontend** to different clusters:

| Overlay | Cluster | Path |
|---------|---------|------|
| PostgreSQL (backend) | OpenShift on-prem | `postgresql/` |
| Frontend | ROSA (public cloud) | `frontend/` |

## On-prem — PostgreSQL

```bash
oc apply -k components/2-tier-todo-app/kustomize/postgresql/
```

Replace the placeholder password in `secret.yaml` (or patch from `byo/`) before applying in a real environment.

## ROSA — Frontend

Configure how the frontend reaches PostgreSQL (possibly on another OpenShift cluster):

1. Set `DB_HOST` in `frontend/configmap.yaml` to a resolvable hostname—commonly the backend **Service DNS** name, for example `todo-postgresql.todo-app.svc.cluster.local`.
2. Align `DB_PASSWORD` in `frontend/secret.yaml` with the database secret.
3. Optionally set `DATABASE_URL` in a Secret instead of the individual `DB_*` variables.

The frontend readiness probe calls `/ready` and only passes when the database is reachable.

```bash
oc apply -k components/2-tier-todo-app/kustomize/frontend/
```

Open the Route hostname in a browser to use the To Do UI.

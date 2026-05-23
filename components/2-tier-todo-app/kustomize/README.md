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

Update `frontend/configmap.yaml` so `DB_HOST` resolves to the on-prem PostgreSQL endpoint reachable from ROSA (VPN, private link, or your platform’s hybrid connectivity). Align `frontend/secret.yaml` `DB_PASSWORD` with the database secret.

```bash
oc apply -k components/2-tier-todo-app/kustomize/frontend/
```

Open the Route hostname in a browser to use the To Do UI.

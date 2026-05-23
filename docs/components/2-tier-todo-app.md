# 2-tier-todo-app

**Component name:** `2-tier-todo-app`  
**Repository path:** [`components/2-tier-todo-app/`](https://github.com/Caseraw/OpenShift-ShowTime/tree/main/components/2-tier-todo-app)

## Purpose

Showcase **2-tier To Do application** for scenario narratives:

- **`todo-frontend`** (Flask) on ROSA — CRUD UI for to do items, namespace `todo-frontend`
- **`todo-postgresql`** (PostgreSQL) on OpenShift on-prem — data tier, namespace `todo-postgresql`

Images are built with podman and published to `quay.io/rh-ee-kamirsar/2-tier-to-do-app` using `{image}-{version}` tags (for example `frontend-0.1.0` and `postgresql-0.1.0`).

The frontend targets PostgreSQL via configurable environment variables (`DB_HOST`, `DATABASE_URL`, and related settings), including OpenShift Service DNS for backends on the same or a peer cluster.

## Layout

- `src/frontend/` — application source and Containerfile
- `src/postgresql/` — PostgreSQL image with schema init
- `kustomize/frontend/` — `todo-frontend` manifests (ROSA)
- `kustomize/postgresql/` — `todo-postgresql` manifests (on-prem)
- `argocd/` — Argo CD Applications `todo-frontend` and `todo-postgresql`
- `automations/build.sh` — build images for a given version
- `automations/build-push.sh` — resolve next version from Quay, build, and push images (no cluster deploy)

## Used by scenarios

None yet — reference this component from a scenario when you wire the hybrid narrative.

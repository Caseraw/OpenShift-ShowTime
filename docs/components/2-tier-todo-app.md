# 2-tier-todo-app

**Component name:** `2-tier-todo-app`  
**Repository path:** [`components/2-tier-todo-app/`](https://github.com/Caseraw/OpenShift-ShowTime/tree/main/components/2-tier-todo-app)

## Purpose

Showcase **2-tier To Do application** for scenario narratives:

- **Frontend** (Flask) on ROSA — CRUD UI for to do items
- **Backend** (PostgreSQL) on OpenShift on-prem — data tier kept in the datacenter

Images are built with podman and published to `quay.io/rh-ee-kamirsar/2-tier-to-do-app`.

The frontend targets PostgreSQL via configurable environment variables (`DB_HOST`, `DATABASE_URL`, and related settings), including OpenShift Service DNS for backends on the same or a peer cluster.

## Layout

- `src/frontend/` — application source and Containerfile
- `src/postgresql/` — PostgreSQL image with schema init
- `kustomize/frontend/` — manifests for ROSA
- `kustomize/postgresql/` — manifests for on-prem
- `automations/build.sh` — build and push images

## Used by scenarios

None yet — reference this component from a scenario when you wire the hybrid narrative.

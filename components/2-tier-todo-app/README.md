# 2-Tier To Do App

A minimal **showcase application** for scenario narratives: a simple To Do UI in the public cloud backed by PostgreSQL in the datacenter.

| Tier | Workload | Platform |
|------|----------|----------|
| Frontend | To Do web app (Flask) | **ROSA** (public cloud) |
| Backend | PostgreSQL database | **OpenShift on-prem** (datacenter) |

The frontend reads, creates, updates, and deletes to do items stored in the on-prem database. Network connectivity between ROSA and the on-prem cluster is a platform concern for your scenario (VPN, private link, etc.).

## Responsibility

This component owns the sample application only:

1. **Source and Containerfiles** — frontend app and PostgreSQL image with schema init.
2. **Kustomize manifests** — separate overlays for on-prem PostgreSQL and ROSA frontend.
3. **Build automation** — podman build and push to Quay.

Cluster provisioning, hybrid networking, and scenario storytelling live in scenarios that reference this component.

## Layout

```
2-tier-todo-app/
├── automations/build.sh          # podman build (and optional push)
├── component.yaml
├── kustomize/
│   ├── frontend/                 # Deploy to ROSA
│   └── postgresql/               # Deploy to on-prem OpenShift
└── src/
    ├── frontend/                 # Flask UI + REST API
    └── postgresql/               # PostgreSQL 16 + todos schema
```

## Prerequisites

- **podman** (included in the repo dev container)
- Quay credentials with push access to `quay.io/rh-ee-kamirsar/2-tier-to-do-app`
- OpenShift on-prem cluster for PostgreSQL
- ROSA cluster for the frontend
- Network path from ROSA to the on-prem PostgreSQL endpoint

## Build images

From the repository root:

```bash
chmod +x components/2-tier-todo-app/automations/build.sh

# Build only
components/2-tier-todo-app/automations/build.sh

# Build and push
PUSH=true components/2-tier-todo-app/automations/build.sh
```

Images published:

| Image | Tag |
|-------|-----|
| `quay.io/rh-ee-kamirsar/2-tier-to-do-app` | `frontend` |
| `quay.io/rh-ee-kamirsar/2-tier-to-do-app` | `postgresql` |

Optional environment variables: `REGISTRY`, `TAG` (default `latest`), `PUSH` (default `false`).

Log in to Quay before pushing:

```bash
podman login quay.io
```

## Deploy

### 1. Backend — on-prem OpenShift

Replace the placeholder database password in `kustomize/postgresql/secret.yaml` (or apply a patch from `byo/`).

```bash
oc login <on-prem-api>
oc new-project todo-app   # or your project
kustomize build components/2-tier-todo-app/kustomize/postgresql | oc apply -f -
```

Note the PostgreSQL hostname or IP that ROSA can reach (Service DNS alone is not enough across clusters unless you expose it on your hybrid network).

### 2. Frontend — ROSA

Set `DB_HOST` in `kustomize/frontend/configmap.yaml` to the on-prem PostgreSQL endpoint. Match `DB_PASSWORD` in `kustomize/frontend/secret.yaml` with the database secret.

```bash
oc login <rosa-api>
oc new-project todo-app
kustomize build components/2-tier-todo-app/kustomize/frontend | oc apply -f -
oc get route todo-frontend -o jsonpath='{.spec.host}{"\n"}'
```

Open the Route URL in a browser. Add, check off, and delete to do items to verify end-to-end connectivity.

## API

The frontend exposes a small REST API used by the UI:

| Method | Path | Action |
|--------|------|--------|
| GET | `/api/todos` | List all items |
| POST | `/api/todos` | Create (`{"title": "..."}`) |
| PUT | `/api/todos/<id>` | Update title and/or done flag |
| DELETE | `/api/todos/<id>` | Remove item |

## Outputs

- Container images in Quay for frontend and PostgreSQL
- Running To Do application demonstrating a hybrid 2-tier pattern

## BYO

| Material | Location |
|----------|----------|
| Quay push/pull credentials | `byo/Credentials/` |
| Database passwords, `DB_HOST` overrides | `byo/Other/` (Kustomize patches, local only) |

Do not commit real passwords. The tracked secrets use `change-me` placeholders.

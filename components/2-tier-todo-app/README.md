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
├── argocd/                       # Argo CD Application manifests
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
chmod +x components/2-tier-todo-app/automations/build-push.sh

# Build only (uses version from component.yaml)
components/2-tier-todo-app/automations/build.sh

# Build locally with an explicit version
VERSION=0.1.2 components/2-tier-todo-app/automations/build.sh
```

### Build and push (recommended)

`build-push.sh` checks Quay for existing `{frontend,postgresql}-X.Y.Z` tags, picks the next patch version, optionally updates local manifest image tags, then **builds and pushes** container images to Quay. It does not deploy to OpenShift.

```bash
podman login quay.io
components/2-tier-todo-app/automations/build-push.sh
```

Version logic:

1. List tags on `quay.io/rh-ee-kamirsar/2-tier-to-do-app` (via `skopeo` or the Quay API).
2. Find the highest semver among `frontend-*` / `postgresql-*` tags and `component.yaml`.
3. If that version already exists in the registry, bump the patch (`0.1.0` → `0.1.1`).
4. Otherwise publish the highest version (first push of a manually bumped `component.yaml`).

Set `UPDATE_MANIFESTS=false` to push without rewriting local YAML, or `VERSION=x.y.z` to force a specific version.

Images published to `quay.io/rh-ee-kamirsar/2-tier-to-do-app` use `{image}-{version}` tags (version from `component.yaml`, currently `0.1.0`):

| Image | Tag | Purpose |
|-------|-----|---------|
| `quay.io/rh-ee-kamirsar/2-tier-to-do-app` | `frontend-0.1.0` | Versioned frontend (used by Kustomize) |
| `quay.io/rh-ee-kamirsar/2-tier-to-do-app` | `postgresql-0.1.0` | Versioned PostgreSQL (used by Kustomize) |
| `quay.io/rh-ee-kamirsar/2-tier-to-do-app` | `frontend-latest` | Latest frontend build |
| `quay.io/rh-ee-kamirsar/2-tier-to-do-app` | `postgresql-latest` | Latest PostgreSQL build |

Optional environment variables: `REGISTRY`, `VERSION` (defaults to `component.yaml` for `build.sh`), `PUSH` (default `false` for `build.sh`).

Log in to Quay before pushing:

```bash
podman login quay.io
PUSH=true VERSION=0.1.0 components/2-tier-todo-app/automations/build.sh
```

Prefer `automations/build-push.sh` for registry-aware version bumps and manifest updates.

## Deploy

### Option A — Argo CD (recommended)

Register two Applications on your Argo CD / OpenShift GitOps instance:

| Application | Namespace | Kustomize path |
|-------------|-----------|----------------|
| `todo-postgresql` | `todo-postgresql` | `kustomize/postgresql/` |
| `todo-frontend` | `todo-frontend` | `kustomize/frontend/` |

```bash
oc apply -k components/2-tier-todo-app/argocd/
```

See [`argocd/README.md`](argocd/README.md) for cluster registration, sync order, and customization. Sync **todo-postgresql** before **todo-frontend**.

### Option B — Manual `oc apply`

#### 1. Backend — todo-postgresql (on-prem OpenShift)

Replace the placeholder database password in `kustomize/postgresql/secret.yaml` (or apply a patch from `byo/`).

```bash
oc login <on-prem-api>
oc apply -k components/2-tier-todo-app/kustomize/postgresql/
```

Note the PostgreSQL hostname or IP that ROSA can reach (Service DNS alone is not enough across clusters unless you expose it on your hybrid network).

On a **fresh database** (empty PVC), the PostgreSQL image automatically loads five sample to do items for demo walkthroughs. Re-deploying against existing data does not re-seed tasks.

#### 2. Frontend — todo-frontend (ROSA)

Point the frontend at the PostgreSQL backend using environment variables (see [Database connection](#database-connection) below). Default `DB_HOST` is `todo-postgresql.todo-postgresql.svc.cluster.local`. Match `DB_PASSWORD` in `kustomize/frontend/secret.yaml` with the database secret.

```bash
oc login <rosa-api>
oc apply -k components/2-tier-todo-app/kustomize/frontend/
oc -n todo-frontend get route todo-frontend -o jsonpath='{.spec.host}{"\n"}'
```

Open the Route URL in a browser. Add, check off, and delete to do items to verify end-to-end connectivity.

## Database connection

The frontend connects to PostgreSQL using **configurable environment variables**. The database may run on the same OpenShift cluster or on a **different cluster** (for example on-prem while the frontend runs on ROSA). Use any hostname that resolves from the frontend pod—OpenShift internal Service notation is supported.

### Option A — individual variables (default)

| Variable | Required | Description |
|----------|----------|-------------|
| `DB_HOST` | Yes* | PostgreSQL host; use Service DNS when applicable |
| `DB_PORT` | No | Port (default `5432`) |
| `DB_NAME` | Yes* | Database name |
| `DB_USER` | Yes* | Database user |
| `DB_PASSWORD` | Yes* | Database password (usually from a Secret) |
| `DB_SSLMODE` | No | `sslmode` for psycopg2 (`require`, `prefer`, `disable`, …) |
| `DB_CONNECT_TIMEOUT` | No | Connection timeout in seconds |

\*Not required when `DATABASE_URL` is set.

**OpenShift Service DNS examples** for the `todo-postgresql` Service:

| Scope | Example `DB_HOST` |
|-------|-------------------|
| Same cluster, short name | `todo-postgresql.todo-postgresql.svc` |
| Same cluster, fully qualified | `todo-postgresql.todo-postgresql.svc.cluster.local` |
| Multi-cluster / Submariner (when configured) | `todo-postgresql.todo-postgresql.svc.clusterset.local` |
| External / hybrid DNS | Hostname your platform exposes to ROSA |

### Option B — single connection URL

Set `DATABASE_URL` instead of the individual variables (takes precedence):

```text
postgresql://todo:password@todo-postgresql.todo-postgresql.svc.cluster.local:5432/todos
```

Store it in a Secret when it contains credentials:

```bash
oc -n todo-frontend create secret generic todo-frontend \
  --from-literal=DATABASE_URL='postgresql://todo:YOUR_PASSWORD@todo-postgresql.todo-postgresql.svc.cluster.local:5432/todos' \
  --dry-run=client -o yaml | oc apply -f -
```

URL-encode special characters in the password.

### Local testing

```bash
podman run -d --name todo-postgresql --network todo-local \
  -e POSTGRES_DB=todos -e POSTGRES_USER=todo -e POSTGRES_PASSWORD=test \
  -e PGDATA=/var/lib/postgresql/data/pgdata \
  quay.io/rh-ee-kamirsar/2-tier-to-do-app:postgresql-latest

podman run -d --name todo-frontend --network todo-local -p 8080:8080 \
  -e DB_HOST=todo-postgresql -e DB_PORT=5432 -e DB_NAME=todos \
  -e DB_USER=todo -e DB_PASSWORD=test \
  quay.io/rh-ee-kamirsar/2-tier-to-do-app:frontend-latest
```

Or with `DATABASE_URL`:

```bash
podman run -d --name todo-frontend --network todo-local -p 8080:8080 \
  -e DATABASE_URL='postgresql://todo:test@todo-postgresql:5432/todos' \
  quay.io/rh-ee-kamirsar/2-tier-to-do-app:frontend-latest
```

Check connectivity: `curl http://127.0.0.1:8080/ready`

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
| Database passwords, `DB_HOST`, `DATABASE_URL` | `byo/Other/` (Kustomize patches, local only) |

Do not commit real passwords. The tracked secrets use `change-me` placeholders.

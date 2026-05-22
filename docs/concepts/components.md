# Components

A **component** is a reusable asset that performs a single function on the OpenShift platform.

## What a component can contain

| Subfolder | Use for |
|-----------|---------|
| `automations/` | Shell scripts, Make targets, or small glue code |
| `ansible/` | Playbooks, roles, and inventory snippets |
| `kustomize/` | Bases and overlays |
| `helm/` | Charts and value files (non-secret defaults only) |

Not every component needs every folder — only what that component requires.

## Naming and metadata

- Use a short, descriptive directory name: `gitops-argocd`, `ldap-bind`, `cert-manager`.
- Each component **must** include a `README.md` describing purpose, prerequisites, inputs, and outputs.
- Optional `component.yaml` (see [project layout](../project-layout.md)) can declare dependencies and interfaces for scenario authors.

## Example skeleton

```
components/
└── my-component/
    ├── README.md
    ├── component.yaml      # optional metadata
    ├── automations/
    │   └── deploy.sh
    ├── ansible/
    │   └── playbooks/
    ├── kustomize/
    │   ├── base/
    │   └── overlays/
    └── helm/
        └── chart/
```

Keep secrets out of components; reference paths under `byo/` in documentation instead.

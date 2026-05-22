# Components

Reusable building blocks that each perform **one function** on the OpenShift platform. Scenarios assemble multiple components into a complete platform story.

## Directory structure

Each component lives in its own subdirectory:

```
components/<component-name>/
├── README.md           # Required — purpose, usage, prerequisites
├── component.yaml      # Optional — metadata (see docs/project-layout.md)
├── automations/        # Scripts, Makefiles, glue
├── ansible/            # Playbooks and roles
├── kustomize/          # Bases and overlays
└── helm/               # Charts and default values (no secrets)
```

## Authoring checklist

- [ ] Single, clear responsibility
- [ ] `README.md` explains inputs, outputs, and dependencies
- [ ] No secrets in tracked files — use `byo/` paths documented in README
- [ ] Automation is idempotent where possible

## Add a new component

```bash
mkdir -p components/my-component/{automations,ansible,kustomize,helm}
touch components/my-component/README.md
```

Copy metadata conventions from [docs/concepts/components.md](../docs/concepts/components.md).

# Scenarios

Each scenario is a **user story**: narrative, goals, and a **demo** that shows the platform built from components.

## Directory structure

```
scenarios/<scenario-id>/
├── README.md           # Required — user story and instructions
├── scenario.yaml       # Optional — component list and metadata
└── demo/               # Example scripts, manifests, walkthrough
    └── README.md
```

## Authoring checklist

- [ ] Narrative explains who, what, why, and how
- [ ] Lists which `components/` are used and in what order
- [ ] Demo is runnable from the dev container (document prerequisites)
- [ ] Secrets and cluster-specific values documented under `byo/`

## Add a new scenario

```bash
mkdir -p scenarios/my-scenario/demo
touch scenarios/my-scenario/README.md scenarios/my-scenario/demo/README.md
```

See [docs/concepts/scenarios.md](../docs/concepts/scenarios.md) for writing guidance.

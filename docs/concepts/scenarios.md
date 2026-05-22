# Scenarios

A **scenario** is a user story: a narrative followed by an example or demo that shows the assembled platform.

## Anatomy of a scenario

| Artifact | Purpose |
|----------|---------|
| `README.md` | User story, prerequisites, success criteria |
| `scenario.yaml` | Machine-readable list of components and ordering (optional) |
| `demo/` | Scripts, manifests, or walkthrough steps for the example |

## Writing the narrative

Good scenarios answer:

- **Who** is the actor (platform engineer, app team, security)?
- **What** outcome do they need?
- **Why** does this platform shape matter?
- **How** do the linked components deliver that outcome?

## Composing components

Scenarios should not duplicate component implementations. Instead, document:

1. Which components are required.
2. In what order they are applied (if order matters).
3. Any scenario-specific configuration that is *not* secret (secrets → `byo/`).

## Example skeleton

```
scenarios/
└── secure-gitops-pipeline/
    ├── README.md
    ├── scenario.yaml
    └── demo/
        ├── README.md
        └── run-demo.sh
```

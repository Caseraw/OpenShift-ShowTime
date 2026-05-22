# Overview

OpenShift ShowTime models platform delivery as **composition**: scenarios describe *what* you are demonstrating; components describe *how* each capability is implemented.

## Design principles

1. **One job per component** — Each component does one thing well (for example: install an operator, configure LDAP, deploy a GitOps controller).
2. **Scenarios tell stories** — A scenario is a user story with context, goals, and a runnable demo.
3. **Reuse over copy-paste** — Scenarios reference components; they do not fork component logic.
4. **Secrets stay local** — Anything sensitive lives under `byo/` and is excluded from git and from this site.

## Typical workflow

1. Pick or author **components** for the integrations you need.
2. Define a **scenario** that lists those components and documents the narrative.
3. Place private keys, vault passwords, and cluster-specific values in **`byo/`**.
4. Run automation from the dev container or your CI environment.

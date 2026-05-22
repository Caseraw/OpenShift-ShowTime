# Project layout

```
OpenShift-ShowTime/
├── .devcontainer/          # Fedora dev environment
├── .github/workflows/      # Docs publish pipeline
├── byo/                    # Local-only secrets (gitignored contents)
├── components/             # Reusable platform building blocks
├── scenarios/              # User stories + demos
├── docs/                   # MkDocs source → GitHub Pages
├── mkdocs.yml
└── requirements-docs.txt
```

## Optional metadata files

### `component.yaml`

```yaml
name: example-component
description: Short summary of what this component does.
version: "0.1.0"
requires:
  - other-component   # optional dependencies
provides:
  - capability-tag    # optional labels for scenario authors
paths:
  ansible: ansible/
  kustomize: kustomize/
  helm: helm/
  automations: automations/
```

### `scenario.yaml`

```yaml
id: example-scenario
title: Human-readable scenario title
summary: One-line description for indexes and docs.
components:
  - name: example-component
    optional: false
demo:
  path: demo/
  entrypoint: demo/run-demo.sh
```

These files are optional but help automation and documentation generators later.

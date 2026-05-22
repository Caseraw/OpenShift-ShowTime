# OpenShift ShowTime

Composable OpenShift platform scenarios built from reusable **components**, each telling a user-story **scenario** with narrative and demo.

## Quick start

### Dev container (Fedora)

Open the repository in a Dev Container (VS Code / Cursor). The image is Fedora-based and includes `oc`, `kubectl`, `helm`, `kustomize`, and Ansible.

```bash
# Preview documentation locally (also available in the dev container)
pip install -r requirements-docs.txt
mkdocs serve
```

### Documentation site

Published to GitHub Pages on every push to `main`. Enable Pages in the repository settings: **Source → GitHub Actions**.

## Repository layout

| Path | Purpose |
|------|---------|
| [`components/`](components/) | Reusable building blocks (Helm, Kustomize, Ansible, scripts) |
| [`scenarios/`](scenarios/) | User stories: narrative + demo, assembled from components |
| [`byo/`](byo/) | **B**ring **Y**our **O**wn — local-only credentials and secrets (not committed) |
| [`docs/`](docs/) | MkDocs source for the public documentation site |
| [`.devcontainer/`](.devcontainer/) | Fedora-based development environment |

See [docs/project-layout.md](docs/project-layout.md) and the published site for full detail.

## BYO (private material)

The `byo/` tree holds material that must never be published: credentials, Ansible Vault files, sealed secrets, and other local assets. Only folder structure and README files are tracked in git; contents are ignored via `.gitignore`.

## License

GPL-3.0 — see [LICENSE](LICENSE).

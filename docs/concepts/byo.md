# BYO — Bring Your Own

The `byo/` directory is for **private, non-publishable** material. Nothing under `byo/` except README files and `.gitkeep` placeholders is committed to git.

## Folders

| Folder | Intended content |
|--------|------------------|
| `Credentials/` | API tokens, kubeconfigs, pull secrets, key files |
| `Ansible-Vault/` | Encrypted vault files and vault passwords (local copies) |
| `Sealed-Secrets/` | SealedSecret manifests or sealing certificates tied to your clusters |
| `Other/` | Anything else that must not leave your machine |

## Practices

- Reference `byo/` paths in component or scenario READMEs; never embed secret values in tracked files.
- Prefer Sealed Secrets or external secret operators for cluster-bound material when scenarios are shared.
- Back up `byo/` separately (password manager, encrypted volume, or your team's secret store).

This documentation site is built from public `docs/` only — **BYO content is never deployed to GitHub Pages**.

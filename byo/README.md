# BYO — Bring Your Own

This tree holds **private, non-publishable** files. Git tracks only this README and the `.gitkeep` files in each subfolder; all other content is ignored (see the root `.gitignore`).

## Subfolders

| Folder | Use for |
|--------|---------|
| [Credentials/](Credentials/) | Tokens, kubeconfigs, registry pull secrets, keys |
| [Ansible-Vault/](Ansible-Vault/) | Vault-encrypted files and local password files |
| [Sealed-Secrets/](Sealed-Secrets/) | SealedSecret YAML and cluster sealing certs |
| [Other/](Other/) | Any other local-only assets |

## Important

- Do **not** commit secrets to the repository.
- Do **not** copy BYO material into `components/` or `scenarios/` tracked paths.
- Back up this directory using your own secure process.

Documentation: [BYO concept](../docs/concepts/byo.md) (also on the GitHub Pages site).

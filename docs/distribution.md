# Distribution

Portico is currently distributed as source in this repository.

The expected flow is:

1. Work from a local checkout.
2. Use the repository workspace and existing build scripts.
3. Import from `Portico` while the API and semantic model settle.

Package distribution comes later. This pre-beta posture does not promise registry publishing, split packages, or a finalized public repository URL.

For now, treat the repo as the source of truth for:

- the semantic site model
- the official theme path
- build and validation helpers
- release hygiene docs

For release-oriented verification in this repo, use `npm run verify`.

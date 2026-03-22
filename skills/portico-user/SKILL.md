---
name: portico-user
description: Bootstrap Portico in a PureScript app during the experimental pre-beta, repo-first period. Use when an app repo needs Portico found or cloned locally, wired through `spago.yaml`, and implemented against the supported `Portico` surface instead of a published package.
---

# Portico User

## Overview

Use this skill when adopting Portico in an application repo before package distribution is ready. Keep the flow source-first, wire a local workspace dependency, and stay on the semantic site path.

## Do Not Use It For

- changing Portico itself as a framework
- assuming registry/package distribution is the normal path
- treating Portico like Asterism-lite, app-shell software, or an interaction-first library

## Workflow

### 1. Find Or Provision The Portico Source

- Prefer an existing local checkout if one is already available.
- Otherwise clone the current Portico repository into a nearby local path.
- If network access is blocked, ask for a local checkout path instead of inventing one.
- Keep in mind that Portico is experimental pre-beta and source-first today.

### 2. Wire The Local Dependency

- Update the consuming app's `spago.yaml` to point at the local Portico checkout in the workspace.
- Use the repo's existing local workspace package pattern if one already exists.
- Keep Portico as a local path dependency until package distribution is official.
- Do not replace the local checkout with a versioned registry dependency.

### 3. Confirm The Supported Surface

- Import from `Portico` first.
- Reach for `Portico.Site`, `Portico.Build`, `Portico.Render`, `Portico.Validate`, `Portico.Theme`, and `Portico.Theme.Official` before inventing app-local substitutes.
- Prefer `validateSite` before treating output as publishable.
- Use `officialTheme` or the `officialThemeWith*` helpers instead of building a parallel theme system.

### 4. Implement The Site Shape

- Model published static sites with semantic primitives such as `site`, `page`, `section`, blocks, navigation, and link helpers.
- Prefer semantic site primitives over raw HTML or ad hoc markup.
- Keep theme concerns separate from the content model.
- If the same missing shape keeps appearing, add or refine a Portico domain primitive instead of scattering custom markup.
- Avoid importing app-state, phase, signal, or browser-app patterns from Asterism-style work.

### 5. Verify And Report Posture

- Run the consuming app's own build or test loop.
- Confirm the code still imports from `Portico` and uses the local workspace checkout.
- Report that Portico is still experimental pre-beta and that package distribution is not the path yet.


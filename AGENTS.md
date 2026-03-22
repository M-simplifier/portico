# Portico Agent Guide

This repository is building toward `Portico`, a PureScript library for published static sites.

## First principles

- Import from `Portico`.
- Prefer semantic site primitives over raw low-level escape hatches.
- Treat the theme layer as separate from the content model.
- Optimize for public information architecture, not app-like interaction.
- If a missing pattern appears repeatedly, add a better domain primitive instead of scattering custom markup.

## Current public direction

The current public root is:

- `src/Portico.purs`

The main families are:

- `Portico.Build`
- `Portico.Site`
- `Portico.Render`
- `Portico.Theme`
- `Portico.Theme.Official`

## Golden path

When extending Portico, follow this order:

1. Clarify the site category and page kinds.
2. Add or refine semantic blocks in `Portico.Site`.
3. Keep design tokens and aesthetic rules in `Portico.Theme`.
4. Improve the official theme without leaking aesthetic detail back into the site model.
5. Only add escape hatches after the semantic path is clear.

## Scope discipline

Portico is for:

- official sites
- docs sites
- portfolios
- essays and publication surfaces
- changelogs and release pages
- event-style microsites

Portico is not for:

- dashboards
- editors
- authenticated apps
- interaction-heavy browser software

If a proposed feature starts pulling the library toward app-shell concerns, stop and check whether it belongs in `Asterism` instead.

## Near-term implementation priorities

- settle the site/page/section/block vocabulary
- strengthen the asset story beyond the first shared stylesheet
- define the official theme system
- grow the sample lab as the main pressure test

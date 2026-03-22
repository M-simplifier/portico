# Public Surface

This note describes the current supported Portico surface during repo-first pre-beta work.

## Supported Entry Point

Import from `Portico`.

That root module is the intended public surface while the site vocabulary, theme system, and build story continue to settle.

## Current Families

- `Portico.Site`
  Site, page, section, block, navigation, link, publish-time metadata, and localized-site primitives.
- `Portico.Build`
  Static file emission helpers such as `emitSite`, `emitMountedSite`, and `emitLocalizedSite`.
- `Portico.Render`
  Pure render helpers such as `renderSite`, `renderStaticSite`, `renderLocalizedSite`, `renderPage`, and `renderStylesheet`.
- `Portico.Validate`
  Publishability diagnostics such as `validateSite`, `validateLocalizedSite`, `siteDiagnostics`, and `hasErrors`.
- `Portico.Theme`
  Theme tokens and layered customization helpers.
- `Portico.Theme.Official`
  The official theme presets and the `officialThemeWith*` customization path.

## Contract Rules

- Prefer semantic site primitives over raw markup.
- Keep theme concerns separate from the content model.
- Prefer route helpers over hand-written internal `href` values.
- Use mounted collection helpers when a site needs to link back into a larger static output tree.
- Run `validateSite` before you treat a site definition as publishable.
- Prefer localized site bundles over client-side copy swapping when a public site needs multiple languages.

## Still Moving

These areas are still expected to move during pre-beta:

- the exact semantic block vocabulary
- validator depth and diagnostics coverage
- the asset story beyond the first shared stylesheet
- the localized-site validator depth and localized build ergonomics
- the long-term package split and package metadata

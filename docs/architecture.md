# Architecture

## Rule

Separate the semantic core from the design system, but keep the default user experience unified.

## Layers

### 1. Semantic core

The core models published-site structure:

- site metadata
- pages
- sections
- semantic blocks
- navigation and linking

This layer should not know about a specific aesthetic direction.

### 2. Theme layer

The theme layer owns:

- color systems
- typography
- spacing and surface rhythm
- component presentation rules
- motion choices that make sense for static-first sites

This layer should not redefine the site model.

### 3. Umbrella layer

The umbrella module exists for the happy path:

- one import
- one official theme
- one obvious default workflow

Internally separated, externally simple.

### 4. Static build layer

Portico should eventually render real multi-page static output:

- HTML documents
- CSS assets
- static routing layout
- metadata and head tags

This is a build-time concern, not an app-runtime concern.

The first useful implementation can stay pure:

- render site values into full HTML documents
- return output paths alongside rendered content
- derive canonical and social metadata from site/page values instead of ad-hoc head markup
- keep localized variants in the static build path, so multiple languages emit real pages instead of runtime-only copy switching
- add filesystem emission only after the document shape settles

The current shape can then add a thin build module:

- `Portico.Build` takes rendered pages and writes them to disk
- the first asset story can stay simple: one shared stylesheet plus relative page links
- public metadata should stay tied to the site model through fields like base URL and social-image targets
- localized bundles should stay tied to the site model too, including `lang`, alternate routes, and `hreflang` output
- publish-time files such as `404.html`, `robots.txt`, and `sitemap.xml` can layer on top without polluting the semantic site DSL
- example-site builders should stay small and declarative
- richer asset pipelines can layer on later without changing the site model

### 5. Validation layer

Portico also needs a pure validation pass between authoring and publishing:

- inspect semantic site values before rendering
- report broken internal routes and duplicate output paths
- catch weak public-surface defaults such as missing summaries
- stay pure and composable so multiple validator passes can be combined

This layer should protect the static-site workflow without turning the authoring surface into type-level ceremony everywhere.

### 6. Optional islands

If Portico later supports light client-side interaction, that should remain optional and carefully bounded.

Examples:

- tabs
- accordion disclosure
- copy buttons
- local theme toggles
- small embedded demonstrations

If a feature wants long-lived state, complex routing, or application-shell behavior, it should probably move toward Asterism rather than expanding Portico.

## Repository Strategy

The repository starts unified, but the conceptual split is already explicit.

Likely future package split:

- `portico-core`
- `portico-official`
- `portico`

The umbrella package should remain the recommended starting point even if the internal packages become separately publishable.

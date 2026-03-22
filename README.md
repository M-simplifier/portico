# Portico

> Experimental pre-beta project.
>
> Portico is one public slice in an "AI building for AI" OSS series. It is
> being released early on purpose, with the repository, docs, official site,
> and sample lab as the main public surface while package distribution, release
> metadata, and the final public contract are still being tightened.
>
> External contribution is welcome, but during pre-beta it is not guaranteed to
> receive a normal OSS response cadence.

Portico is a PureScript library for published static sites: official project sites, documentation surfaces, portfolios, essays, release pages, and other content-first web artifacts that should deploy cleanly as static hosting output.

It is not trying to be a lighter `Asterism`. The center of gravity is different. `Asterism` is for time-heavy interactive applications; `Portico` is for public-facing, content-first sites with light interaction, strong information architecture, and a fast path to good visual quality.

## Status

Portico is still pre-beta.

This is an early repo-first release posture, not a stable package release.

The current public posture is intentionally narrow:

- the repository is the source of truth
- the Portico-authored official site and mounted sample lab are the main onboarding surface
- local evaluation and local workspace consumption are the supported adoption path today
- package publishing and broader distribution promises are intentionally held until the public surface settles

This repository currently establishes:

- the domain and scope
- the core/theme split
- the initial public module root `Portico`
- a small typed site DSL skeleton
- a first static HTML renderer
- a first shared stylesheet asset path
- a first file emission path
- a first validation layer for static-site diagnostics
- route helpers for internal and collection-level links
- metric, timeline, code, image, people, quote, and FAQ blocks for pressure-tested site shapes
- official theme presets plus accent/palette/typography overrides
- canonical plus OG/Twitter metadata derived from the site/page model
- localized site bundles with per-locale static routes, `lang`, and `hreflang` alternates
- a Portico-built official site with the sample lab mounted alongside it
- a GitHub Pages-ready public build path with `404.html`, `robots.txt`, and `sitemap.xml`
- an MIT license for repo-first public evaluation
- a sample lab with six generated site surfaces
- agent and continuity docs for future implementation work

## Start Here

Run the official site locally:

```sh
npm install
npm run dev
```

Then use the built-in path:

- `Front door`: the home page and current status
- `Getting Started`: the shortest supported authoring path
- `Theme System`: the official theme selection and customization path
- `Publishability`: validation, build output, and deploy-oriented metadata
- `Release`: the current working-slice note
- `Sample Lab`: the pressure-test chooser and generated public surfaces

## Scope

Portico is being shaped around one category:

- published static sites

That category is intentionally broader than "OSS official site" but narrower than "frontend in general".

Good fits:

- library and framework sites
- docs and guide sites
- product landing pages with light interaction
- release notes and changelog surfaces
- portfolios and case-study pages
- essays, notes, and small publication sites
- event or campaign microsites

Explicitly not the primary target:

- dashboards
- editors
- authenticated apps
- realtime control surfaces
- large CMS-style site builders
- interaction-heavy browser software

## Design Shape

Portico follows one rule:

- separate the semantic site DSL from the design system, but keep the default user experience unified

That means:

- `Portico.Build` writes rendered pages to static output paths
- `Portico.Site` holds content and information-architecture primitives
- `Portico.Render` turns semantic site descriptions into themed static HTML documents, either inline or with a shared stylesheet asset
- `Portico.Theme` holds design-token level concerns
- `Portico.Theme.Official` is the fast default for attractive results
- `Portico` re-exports the happy path so AI agents and humans can start from one import

The likely long-term package split is:

- `portico-core`
- `portico-official`
- `portico`

But the repository starts unified so the concepts can settle before registry packaging is frozen.

## First Principles

- Static-first, not app-first
- Semantic DSL, not raw `div` soup
- Good-looking default output is part of the product, not an afterthought
- AI-friendly happy path first, deeper escape hatches second
- Strong category boundaries: public information surfaces, not browser software

## Initial Example

```purescript
import Portico

guideSlug = "guide/getting-started"

exampleSite =
  withNavigation
    [ slugNavItem "Guide" guideSlug ]
    (site "Portico"
      [ withSummary
          "Static-first sites for docs, releases, and public-facing product surfaces."
          (page "index" Landing "Portico"
            [ namedSection "Intro"
                [ HeroBlock
                    (withActions
                      [ slugLinkCard "Read the guide" guideSlug (Just "Start from the supported path.")
                      ]
                      (withEyebrow
                        "Semantic static sites"
                        (hero
                          "Published surfaces in PureScript."
                          "Portico focuses on content-first sites with clear structure and a strong default look.")))
                ]
            ])
      , page guideSlug Documentation "Guide"
          [ namedSection "Start here"
              [ ProseBlock "Use route helpers for internal links so generated pages stay subpath-safe."
              ]
          ]
      ])

renderedPages =
  renderSite officialTheme exampleSite

main =
  emitSite "examples/official/dist" officialTheme exampleSite
```

`renderSite` keeps styles inline, which is useful for quick previews and testing.

`emitSite` writes a shared stylesheet to `assets/portico.css` and rewrites page documents to link it with the correct relative `href`.

If you want publishable head metadata, add a deployment base URL and optional social images:

```purescript
publicSite =
  withBaseUrl "https://example.com/portico"
    (withDefaultSocialImage
      (ExternalAsset "https://cdn.example.com/portico-card.png")
      exampleSite)

guidePage =
  withSocialImage
    (SiteAsset "assets/guide-card.svg")
    (page "guide/getting-started" Documentation "Guide" ...)
```

With `withBaseUrl`, Portico emits canonical URLs plus `og:url`. With `withDefaultSocialImage` and `withSocialImage`, it can also emit `og:image` and `twitter:image` without pushing raw head markup back into the page model.

If you want a localized static site, keep one full `Site` per locale and emit them together:

```purescript
import Portico

localizedDefinition =
  localizedSite
    englishLocale
    [ localizedVariant englishLocale "English" "" englishSite
    , localizedVariant japaneseLocale "日本語" "ja" japaneseSite
    ]

main = do
  let report = validateLocalizedSite localizedDefinition
  emitLocalizedSite "site/dist" officialTheme localizedDefinition
```

That path stays static-first: each locale emits real pages, the renderer sets `lang`, and alternate pages can emit `hreflang` when a base URL is available. Language switching is meant to stay link-based, not to turn the site into a client-side app.

For internal links, prefer `slugNavItem`, `slugLinkCard`, `pageNavItem`, or `pageLinkCard` over raw `href` strings. Those helpers let Portico render relative links correctly from nested pages.

If you are emitting a site as part of a larger mounted collection, use `collectionLinkCard` / `collectionNavItem` with `emitMountedSite` so links can safely escape the current site mount without falling back to hand-written `../../..` paths.

For docs-style pages, prefer `CodeBlock` with `codeSample` over burying examples inside prose. That keeps examples first-class in the site model and gives the theme a stable place to style them.

For media-bearing surfaces, use `ImageBlock` with `siteImage` or `collectionImage` so visual assets can stay route-aware under mounted static output. The in-repo sample lab currently uses only self-authored SVG assets for this purpose.

For design, start with `officialTheme`, move to `officialThemeWithPreset` when one of the built-in voices fits, and use `officialThemeWithAccent` or `officialThemeWithPalette` when you want a custom palette while staying on the official theme system. Typography, spacing, surface/chrome, radius, and shadow can still be overridden separately with `withTypography`, `withSpacing`, `withSurface`, `withRadius`, and `withShadow`.

If you want one code-first entry point for preset selection plus layered overrides, use `officialThemeWith`:

```purescript
launchTheme =
  officialThemeWith
    ((officialThemeOptions SignalPaper)
      { accent = Just "#0f766e"
      , spacing = Just
          { pageInset: "3.2rem"
          , pageTop: "4.7rem"
          , pageBottom: "5.6rem"
          , sectionGap: "3.2rem"
          , stackGap: "1.3rem"
          , cardPadding: "1.4rem"
          , heroPadding: "2.35rem"
          }
      })
```

The current official presets are intentionally directional rather than cosmetic variants:

- `SignalPaper`: the calm default for docs and official project surfaces
- `CopperLedger`: a tighter, warmer studio or portfolio voice
- `NightCircuit`: a dark, wider technical launch or event voice
- `BlueLedger`: a narrower publication or notebook voice

For verification, use `validateSite` before treating a site definition as publishable. The first validator pass checks things like missing `index.html`, duplicate page paths, empty navigation or link-card labels, broken internal `SitePath` links, duplicate section ids, missing summaries, and misplaced hero blocks.

For localized bundles, use `validateLocalizedSite` and `hasLocalizedErrors`. That layer checks the per-locale site diagnostics too, and it can warn when one locale is missing a page that exists in another locale variant.

`npm run build:example` builds the standalone pressure-test sample lab at `examples/official/dist`.

`npm run build:site` builds a Portico-authored official site at `site/dist`, with the sample lab mounted under `lab/` and the generated sample surfaces still available under `samples/`. This is the current dogfooding path for the future public site.

`npm run build:pages` is the GitHub Pages-oriented variant. It injects a canonical base URL, then emits `404.html`, `robots.txt`, and `sitemap.xml` alongside the rest of `site/dist`.

## Commands

After installing dev dependencies:

```sh
npm run check
npm run verify
npm run dev
npm run screenshot:site
npm run build:example
npm run build:site
npm run build:pages
```

`npm run verify` is the release-oriented gate. It runs the test suite, rebuilds the standalone sample lab, rebuilds the Portico-authored official site, and verifies the GitHub Pages-oriented output with a deterministic placeholder base URL.

`npm run dev` builds the Portico-authored official site, serves `site/dist`, and rebuilds automatically when the local source/docs change.

`npm run screenshot:site` builds and serves the official site long enough to capture a default review set of screenshots into `site/review`.

For the deployment path itself, see [docs/deployment.md](docs/deployment.md).

## Docs Map

- [CONTRIBUTING.md](CONTRIBUTING.md): public contribution expectations during pre-beta
- [CHANGELOG.md](CHANGELOG.md): tracked repo-visible changes
- [docs/README.md](docs/README.md): docs index by goal
- [docs/agent-quickstart.md](docs/agent-quickstart.md): AI-oriented implementation path
- [docs/reference/public-surface.md](docs/reference/public-surface.md): current supported public module families
- [docs/deployment.md](docs/deployment.md): GitHub Pages and base-URL deployment flow
- [docs/distribution.md](docs/distribution.md): repo-first now, package path later
- [docs/release-checklist.md](docs/release-checklist.md): pre-beta release gate and publication checklist

## Repo-First Pre-Beta Gate

Portico is not at registry-publish stage yet. The current public-alpha gate is:

- the sample lab should stay strong enough to act as a real chooser, not only as a demo gallery
- `validateSite` should run cleanly on the official examples and sample surfaces
- build output should cover the minimum practical static-site story: relative links, shared CSS, assets, canonical/social metadata, and publish-time files like `404.html`, `robots.txt`, and `sitemap.xml`
- the README and preset catalog should be enough for another AI to produce one working site without bespoke hand-holding
- `npm run verify` should stay green as the canonical release-oriented gate
- public release docs and contribution posture should stay aligned with the actual repository state

## Next

The next implementation pass should add:

- richer validators and build-time diagnostics
- shared CSS/assets beyond the first stylesheet
- one official theme that already feels intentional
- a stronger sample lab that keeps exposing weak spots in the site model
- package metadata and release metadata once the final public repository location exists

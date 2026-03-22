module Example.Official.Site
  ( officialSite
  ) where

import Data.Maybe (Maybe(..))
import Portico
  ( Block(..)
  , CalloutTone(..)
  , PageKind(..)
  , Site
  , callout
  , collectionLinkCard
  , collectionNavItem
  , codeSample
  , faqEntry
  , feature
  , hero
  , metric
  , namedSection
  , page
  , site
  , slugLinkCard
  , slugNavItem
  , timelineEntry
  , withActions
  , withDescription
  , withEyebrow
  , withNavigation
  , withSummary
  )

officialSite :: Site
officialSite =
  withNavigation
    [ slugNavItem "Guide" "guide/getting-started"
    , slugNavItem "Themes" "guide/theme-system"
    , slugNavItem "Publishability" "guide/publishability"
    , slugNavItem "Release" "releases/0-1-0"
    , collectionNavItem "Sample Lab" "lab/index.html"
    ]
      (withDescription
      "Portico is a PureScript library for published static sites, built around semantic site structure, theme discipline, and static output. It is one repo-first slice of an AI-building-for-AI OSS series."
      (site
        "Portico"
        [ homePage
        , guidePage
        , themePage
        , publishabilityPage
        , releasePage
        ]))
  where
  homePage =
    withSummary
      "Semantic pages, official theme selection, validation, and static build output for public-facing sites in a repo-first pre-beta slice."
      (page
        "index"
        Landing
        "Portico"
        [ namedSection
            "Front door"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "Read the guide" "guide/getting-started" (Just "Start with the supported authoring path.")
                  , collectionLinkCard "Explore the sample lab" "lab/index.html" (Just "Pressure-test the DSL across multiple public site shapes.")
                  , collectionLinkCard "Open the preset catalog" "lab/presets.html" (Just "Choose a theme by site intent rather than by accent.")
                  ]
                  (withEyebrow
                    "AI-building-for-AI OSS series"
                    (hero
                      "Published surfaces in PureScript."
                      "Portico models docs, release pages, portfolios, and other public surfaces as semantic site data instead of app-shell UI. This slice is experimental, and contribution response is not guaranteed during pre-beta.")))
            , FeatureGridBlock
                [ feature "Semantic DSL" "Keep public information architecture explicit instead of scattering ad hoc markup."
                , feature "Official theme system" "Choose a preset by site shape, then customize in layers without collapsing back into raw CSS decisions."
                , feature "Validation pass" "Run publishability checks before treating a site definition as release-ready."
                , feature "Static build" "Render and emit multi-page HTML, assets, and metadata without app-shell overhead."
                ]
            , MetricsBlock
                [ metric "6" "sample site shapes" (Just "Docs, product, portfolio, profile, event, and publication surfaces pressure-test the DSL.")
                , metric "4" "official presets" (Just "Directional defaults for calm docs, warm studios, bold launches, and quiet publication surfaces.")
                , metric "1" "validation layer" (Just "Broken routes, duplicate paths, weak summaries, and misplaced heroes are checked before publish.")
                ]
            ]
        , namedSection
            "Paths"
            [ LinkGridBlock
                [ slugLinkCard "Getting started" "guide/getting-started" (Just "The shortest supported path through the library.")
                , slugLinkCard "Theme system" "guide/theme-system" (Just "How preset choice and layered customization fit together.")
                , slugLinkCard "Publishability" "guide/publishability" (Just "Validation, build output, and deploy-oriented metadata.")
                , slugLinkCard "Release 0.1.0" "releases/0-1-0" (Just "Track the first working slice.")
                ]
            ]
        , namedSection
            "Current posture"
            [ CalloutBlock
                (callout Quiet "Repo-first pre-beta" "Portico is being published as an experimental AI-building-for-AI OSS series slice. The official site, mounted sample lab, validation, deploy-oriented output, and release-oriented verification are all in place, while contribution response is intentionally not guaranteed until the public contract settles.")
            , TimelineBlock
                [ timelineEntry "Official site" "The root site is now authored in Portico itself, so the library is pressure-testing its own docs and front door as public truth." Nothing
                , timelineEntry "Mounted sample lab" "The chooser now lives alongside the official site rather than existing only as an isolated demo gallery." Nothing
                , timelineEntry "Release gate" "A single `npm run verify` path now checks the typed core plus standalone, official-site, and GitHub Pages-oriented builds." Nothing
                , timelineEntry "Contributor posture" "Contributions are welcome, but the pre-beta OSS cadence is intentionally experimental rather than guaranteed." Nothing
                ]
            ]
        ])

  guidePage =
    withSummary
      "The shortest supported path through Portico."
      (page
        "guide/getting-started"
        Documentation
        "Getting Started"
        [ namedSection
            "Golden path"
            [ ProseBlock "Import from Portico, stay on the semantic path, and let the renderer own the HTML document."
            , TimelineBlock
                [ timelineEntry "1. Model the site" "Start from `site`, `page`, `section`, and semantic blocks instead of raw HTML fragments." Nothing
                , timelineEntry "2. Choose the voice" "Pick an official preset, then layer accent or structural overrides only if the site needs them." Nothing
                , timelineEntry "3. Validate and emit" "Run `validateSite`, then render or emit static output once the public surface is coherent." Nothing
                ]
            , CodeBlock
                (codeSample
                  "import Portico\n\nsiteDefinition =\n  site \"Portico\"\n    [ page \"index\" Landing \"Portico\"\n        [ namedSection \"Intro\"\n            [ ProseBlock \"Stay on the semantic path.\" ]\n        ]\n    ]"
                  (Just "purescript")
                  (Just "Minimal site definition"))
            , CalloutBlock
                (callout Accent "Use the public vocabulary" "If you need a pattern repeatedly, add a site primitive instead of scattering markup.")
            , LinkGridBlock
                [ slugLinkCard "Return home" "index" (Just "See the official overview.")
                , slugLinkCard "Go to the theme guide" "guide/theme-system" (Just "Move from structure into preset selection and customization.")
                , slugLinkCard "Read the release note" "releases/0-1-0" Nothing
                ]
            ]
        ])

  themePage =
    withSummary
      "How official presets and layered customization fit together."
      (page
        "guide/theme-system"
        Documentation
        "Theme System"
        [ namedSection
            "Selection"
            [ ProseBlock "Portico separates the semantic site model from the theme system, but the official path is still opinionated enough to produce strong public surfaces quickly."
            , FeatureGridBlock
                [ feature "Start from intent" "Choose docs, studio, launch, or publication posture before you start thinking about accent color."
                , feature "Customize in layers" "Accent, palette, typography, spacing, surface, radius, and shadow sit on top of the official system instead of replacing it."
                , feature "Keep the DSL semantic" "Theme detail belongs in the theme layer, not in the page model."
                ]
            ]
        , namedSection
            "Customization ladder"
            [ CodeBlock
                (codeSample
                  "import Portico\n\nlaunchTheme =\n  officialThemeWith\n    ((officialThemeOptions SignalPaper)\n      { accent = Just \"#0f766e\"\n      , spacing = Just\n          { pageInset: \"3.2rem\"\n          , pageTop: \"4.7rem\"\n          , pageBottom: \"5.6rem\"\n          , sectionGap: \"3.2rem\"\n          , stackGap: \"1.3rem\"\n          , cardPadding: \"1.4rem\"\n          , heroPadding: \"2.35rem\"\n          }\n      })"
                  (Just "purescript")
                  (Just "One code-first entry point for official-theme customization"))
            , LinkGridBlock
                [ collectionLinkCard "Browse the preset catalog" "lab/presets.html" (Just "See the presets mapped to generated sample surfaces.")
                , collectionLinkCard "Compare the sample lab" "lab/index.html" (Just "Pressure-test the current theme system across multiple site categories.")
                , slugLinkCard "Read the getting started guide" "guide/getting-started" (Just "Return to the supported semantic authoring path.")
                ]
            ]
        ])

  publishabilityPage =
    withSummary
      "Validation, build output, and deploy-oriented metadata for public surfaces."
      (page
        "guide/publishability"
        Documentation
        "Publishability"
        [ namedSection
            "Checks"
            [ FeatureGridBlock
                [ feature "Validator first" "Check for missing index pages, duplicate paths, broken internal routes, weak summaries, and misplaced heroes before publish."
                , feature "Metadata from the model" "Canonical, OG, and Twitter tags are derived from site/page values instead of raw head markup."
                , feature "Static output" "Emit files that stay subpath-safe under nested routes and shared CSS assets."
                ]
            , CodeBlock
                (codeSample
                  "import Portico\n\nreport = validateSite siteDefinition\nsiteHasErrors = hasErrors siteDefinition\n\nmain =\n  emitSite \"site/dist\" officialTheme siteDefinition"
                  (Just "purescript")
                  (Just "Validation before emission"))
            ]
        , namedSection
            "Build path"
            [ TimelineBlock
                [ timelineEntry "Render" "Use `renderSite` for quick inspection or inline previews while the page model is still moving." Nothing
                , timelineEntry "Validate" "Use `validateSite` as the publishability gate before treating a site definition as release-ready." Nothing
                , timelineEntry "Emit" "Use `emitSite` or `emitMountedSite` once the surface is ready for static hosting output." Nothing
                ]
            , FaqBlock
                [ faqEntry "Do I need a base URL to render?" "No. Base URLs matter when you want canonical and social metadata, not when you are still previewing locally."
                , faqEntry "Should I hand-write relative links?" "Prefer route helpers and mounted collection helpers so nested output stays coherent."
                , faqEntry "What is the release-oriented repo check?" "Use `npm run verify`. It composes tests with standalone sample-lab, official-site, and GitHub Pages-style build output."
                , faqEntry "Is Portico trying to be a static CMS?" "No. The target is authored static surfaces with strong information architecture, not content-management tooling."
                ]
            ]
        ])

  releasePage =
    withSummary
      "The first working slice of Portico."
      (page
        "releases/0-1-0"
        ReleaseNotes
        "Release 0.1.0"
        [ namedSection
            "Highlights"
            [ FeatureGridBlock
                [ feature "Typed site model" "Site, page, section, and block vocabulary are now in place."
                , feature "HTML renderer" "Theme-aware document rendering ships as the first real output path."
                , feature "Build path" "Rendered pages can now be emitted as actual files with shared CSS, canonical/social metadata support, and a single release-oriented verify path."
                ]
            , CalloutBlock
                (callout Strong "Status" "Portico is early, but it now has a repo-first pre-beta path from semantic data to validated, deploy-oriented static output.")
            ]
        ])

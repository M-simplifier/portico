module Example.Official.Site
  ( officialSite
  , officialSiteTheme
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Portico
  ( Block(..)
  , CalloutTone(..)
  , OfficialPreset(..)
  , PageKind(..)
  , Site
  , Theme
  , callout
  , collectionLinkCard
  , collectionNavItem
  , codeSample
  , faqEntry
  , feature
  , hero
  , linkCard
  , metric
  , namedSection
  , navItem
  , officialThemeOptions
  , officialThemeWith
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

officialSiteTheme :: Theme
officialSiteTheme =
  officialThemeWith
    ((officialThemeOptions SignalPaper)
      { palette = Just
          { background: "#eef4ff"
          , panel: "#fbfdff"
          , text: "#0f172a"
          , mutedText: "#475569"
          , accent: "#2563eb"
          , border: "#d9e4f5"
          }
      , typography = Just
          { display: "\"Space Grotesk\", \"Hiragino Sans\", \"Yu Gothic UI\", \"Yu Gothic\", \"Noto Sans JP\", sans-serif"
          , body: "\"Public Sans\", \"Hiragino Sans\", \"Yu Gothic UI\", \"Yu Gothic\", \"Noto Sans JP\", sans-serif"
          , mono: "\"IBM Plex Mono\", \"SFMono-Regular\", \"Hiragino Sans\", \"Yu Gothic UI\", \"Noto Sans Mono CJK JP\", monospace"
          }
      , spacing = Just
          { pageInset: "3.6rem"
          , pageTop: "4.7rem"
          , pageBottom: "6rem"
          , sectionGap: "4.2rem"
          , stackGap: "1.35rem"
          , cardPadding: "1.45rem"
          , heroPadding: "2.7rem"
          }
      , surface = Just
          { frameWidth: "76rem"
          , brandRadius: "1rem"
          , pillRadius: "999px"
          , headerSurface: "color-mix(in srgb,var(--panel) 86%,white)"
          , heroSurface: "linear-gradient(140deg,#ffffff 0%,color-mix(in srgb,var(--accent) 12%,white) 38%,color-mix(in srgb,var(--accent) 24%,#dbeafe) 100%)"
          , quoteSurface: "linear-gradient(145deg,color-mix(in srgb,var(--accent) 10%,white) 0%,var(--panel) 100%)"
          }
      , radius = Just "28px"
      , shadow = Just "0 36px 100px rgba(15, 23, 42, 0.24)"
      })

officialSite :: Site
officialSite =
  withNavigation
    [ slugNavItem "Start" startSlug
    , slugNavItem "Themes" themeSlug
    , slugNavItem "Publish" publishabilitySlug
    , slugNavItem "Reference" referenceSlug
    , collectionNavItem "Lab" labHomePath
    , navItem "GitHub" githubRepositoryHref
    ]
    (withDescription
      "Static sites in PureScript for docs, project front doors, release pages, portfolios, and editorial surfaces."
      (site
        "Portico"
        [ homePage
        , whyPage
        , startPage
        , aiPage
        , referencePage
        , themePage
        , publishabilityPage
        , releasePage
        ]))
  where
  whySlug = "learn/fit"

  startSlug = "guide/getting-started"

  aiPathSlug = "guide/ai-path"

  referenceSlug = "reference/public-surface"

  themeSlug = "guide/theme-system"

  publishabilitySlug = "guide/publishability"

  releaseSlug = "releases/0-1-0"

  labHomePath = "lab/index.html"

  presetCatalogPath = "lab/presets.html"

  docsSamplePath = "samples/northline-docs/index.html"

  productSamplePath = "samples/northstar-cloud/index.html"

  profileSamplePath = "samples/mina-arai/index.html"

  summitSamplePath = "samples/signal-summit/index.html"

  githubRepositoryHref = "https://github.com/M-simplifier/portico"

  githubAgentQuickstartHref = githubRepositoryHref <> "/blob/main/docs/agent-quickstart.md"

  githubSkillHref = githubRepositoryHref <> "/blob/main/skills/portico-user/SKILL.md"

  githubVisionHref = githubRepositoryHref <> "/blob/main/docs/vision.md"

  githubArchitectureHref = githubRepositoryHref <> "/blob/main/docs/architecture.md"

  githubDeploymentHref = githubRepositoryHref <> "/blob/main/docs/deployment.md"

  githubDistributionHref = githubRepositoryHref <> "/blob/main/docs/distribution.md"

  githubReleaseChecklistHref = githubRepositoryHref <> "/blob/main/docs/release-checklist.md"

  gettingStartedCode =
    "import Portico\n\nsiteDefinition =\n  site \"Signal Manual\"\n    [ withSummary\n        \"A calm docs front door.\"\n        (page \"index\" Landing \"Signal Manual\"\n          [ namedSection \"Overview\"\n              [ HeroBlock\n                  (withEyebrow\n                    \"Published public surfaces\"\n                    (hero\n                      \"Build a real front door.\"\n                      \"Model the site semantically and keep the path static-first.\"))\n              ]\n          ])\n    ]\n\nmain = do\n  let report = validateSite siteDefinition\n  emitSite \"site/dist\" officialTheme siteDefinition"

  themeCode =
    "import Portico\n\nsiteTheme =\n  officialThemeWith\n    ((officialThemeOptions SignalPaper)\n      { accent = Just \"#2563eb\"\n      , spacing = Just\n          { pageInset: \"3.6rem\"\n          , pageTop: \"4.7rem\"\n          , pageBottom: \"6rem\"\n          , sectionGap: \"4.2rem\"\n          , stackGap: \"1.35rem\"\n          , cardPadding: \"1.45rem\"\n          , heroPadding: \"2.7rem\"\n          }\n      })"

  localizedCode =
    "import Portico\n\nlocalizedDefinition =\n  localizedSite\n    englishLocale\n    [ localizedVariant englishLocale \"English\" \"\" englishSite\n    , localizedVariant japaneseLocale \"Japanese\" \"ja\" japaneseSite\n    ]\n\nmain = do\n  let report = validateLocalizedSite localizedDefinition\n  emitLocalizedSite \"site/dist\" officialTheme localizedDefinition"

  aiChecklistCode =
    "Use Portico for published static sites.\nImport from Portico.\nPrefer site, page, section, and semantic blocks.\nUse route helpers instead of hand-written relative links.\nKeep theme concerns separate from content structure.\nRun validateSite or validateLocalizedSite before publish.\nEmit output with emitSite, emitMountedSite, or emitLocalizedSite."

  homePage =
    withSummary
      "Static sites with a real front door: semantic structure, official themes, validation, and clean multi-page output in PureScript."
      (page
        "index"
        Landing
        "Portico"
        [ namedSection
            "Overview"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "Start here" startSlug (Just "Move from one import to a working site and a publishable build.")
                  , collectionLinkCard "Browse the sample lab" labHomePath (Just "See docs, landing, portfolio, event, and editorial surfaces emitted by Portico.")
                  , linkCard "Open GitHub" githubRepositoryHref (Just "Read the repo, docs, and current pre-beta public surface.")
                  ]
                  (withEyebrow
                    "Published public surfaces"
                    (hero
                      "Build static sites with a real front door."
                      "Portico is a PureScript library for docs, project sites, release pages, portfolios, and editorial surfaces. Write site structure semantically, start from an official theme, validate before publish, and emit clean static output.")))
            , MetricsBlock
                [ metric "`Portico`" "Public happy path" (Just "One import across site model, themes, render, validate, and build.")
                , metric "6" "Pressure-tested surfaces" (Just "Docs, product, portfolio, profile, event, and publication surfaces.")
                , metric "2 locales" "Localized official site" (Just "English at the root and Japanese under /ja/.")
                , metric "`npm run verify`" "Release gate" (Just "Checks tests, official-site builds, and GitHub Pages output.")
                ]
            , CodeBlock
                (codeSample
                  gettingStartedCode
                  (Just "purescript")
                  (Just "From site model to static output"))
            ]
        , namedSection
            "Why Portico exists"
            [ ProseBlock "Most site tooling starts with templates, markdown pipelines, or raw layout freedom. Portico starts one layer higher: the public information architecture of a publishable site."
            , FeatureGridBlock
                [ feature "Semantic site model" "Keep site, page, section, navigation, and content blocks explicit instead of hiding them inside ad hoc markup."
                , feature "Official theme system" "Start from a strong visual voice, then tune palette, typography, spacing, and chrome in layers."
                , feature "Publish-time checks" "Catch broken routes, missing summaries, duplicate sections, and weak metadata before release."
                , feature "Static-first localization" "Emit real locale variants with real routes, lang attributes, and alternate metadata."
                ]
            , CalloutBlock
                (callout Strong "Not Asterism-lite" "If the surface wants authenticated flows, long-lived state, or app-shell behavior, the design center has already moved out of Portico.")
            ]
        , namedSection
            "What it is good at"
            [ FeatureGridBlock
                [ feature "Official project sites" "Front doors that need a clear promise, a docs path, and a release-adjacent information architecture."
                , feature "Docs and guides" "Concept pages, getting-started flows, nested reference, and calm technical reading without app-shell drift."
                , feature "Release and changelog pages" "Published updates with stable routing, metadata, and a durable static output story."
                , feature "Editorial and portfolio surfaces" "Case studies, essays, notes, and smaller publication sites that still need intentional structure."
                ]
            , LinkGridBlock
                [ slugLinkCard "Read why it fits" whySlug (Just "See the category boundary, scope, and design center in one place.")
                , slugLinkCard "Read the AI workflow" aiPathSlug (Just "Keep implementation agents on the same narrow authoring lane.")
                , slugLinkCard "Read the reference" referenceSlug (Just "See the current public module families and contract rules.")
                , slugLinkCard "Start here" startSlug (Just "Go straight to the smallest useful authoring path.")
                ]
            ]
        , namedSection
            "Proof in the open"
            [ CalloutBlock
                (callout Accent "Dogfooded on purpose" "The official site, its Japanese variant, and the mounted sample lab are all emitted by Portico. The proof surface is meant to pressure the library, not to sit beside it.")
            , LinkGridBlock
                [ collectionLinkCard "Browse the sample lab" labHomePath (Just "Explore the broader pressure-test gallery across multiple public site shapes.")
                , collectionLinkCard "Open the preset catalog" presetCatalogPath (Just "Choose a theme by site intent before you fine-tune it.")
                , slugLinkCard "Read the theme system" themeSlug (Just "See how presets and layered customization fit together.")
                , slugLinkCard "Read publishability" publishabilitySlug (Just "Review validation, metadata, localized output, and deploy-oriented files.")
                ]
            ]
        , namedSection
            "Release posture"
            [ CalloutBlock
                (callout Quiet "Public pre-beta" "Portico is live and usable now, but the public contract is still settling. The repository, official site, and npm run verify are the current source of truth.")
            , LinkGridBlock
                [ slugLinkCard "Read release 0.1.0" releaseSlug (Just "See what is shipped, what is stable enough to evaluate, and what still needs pressure.")
                , linkCard "Open the GitHub repository" githubRepositoryHref (Just "Use the repo for code, docs, issues, and current release posture.")
                , linkCard "Read the deployment guide" githubDeploymentHref (Just "See the GitHub Pages-oriented base-url and publishing flow.")
                , linkCard "Read contribution expectations" (githubRepositoryHref <> "/blob/main/CONTRIBUTING.md") (Just "Current pre-beta contribution posture and response expectations.")
                ]
            ]
        ])

  whyPage =
    withSummary
      "Where Portico fits and why its scope stays narrow."
      (page
        whySlug
        (CustomKind "Why")
        "Why Portico"
        [ namedSection
            "Design center"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "Start here" startSlug (Just "Use the smallest path from site definition to emitted pages.")
                  , slugLinkCard "Read publishability" publishabilitySlug (Just "See the release-facing validation and metadata story.")
                  , collectionLinkCard "Browse the sample lab" labHomePath (Just "Pressure-test the library across multiple site categories.")
                  ]
                  (withEyebrow
                    "Scope"
                    (hero
                      "A static-site library should understand public structure."
                      "Portico exists for published public surfaces: the parts of the web that need promise, path, proof, and calm reading rhythm without turning into an app shell.")))
            , FeatureGridBlock
                [ feature "Official sites" "Project front doors that need to explain what a thing is, how to start, and where deeper docs live."
                , feature "Docs and learning surfaces" "Concept pages, nested reference, and release adjacency for readers who are there to understand, not operate software."
                , feature "Release communication" "Changelog, release, and rollout pages that should survive static hosting and subpath deployment cleanly."
                , feature "Editorial surfaces" "Portfolios, essays, notes, and publication-style pages where structure matters more than interaction density."
                ]
            , CalloutBlock
                (callout Strong "Out of scope on purpose" "Dashboards, editors, authenticated apps, and interaction-heavy browser software want a different runtime model. That is where Asterism should take over.")
            ]
        , namedSection
            "The product idea"
            [ ProseBlock "Portico is not trying to be every kind of website tool. It is trying to be unusually clear and effective for a narrower category: static public sites that need to look intentional, stay legible to implementation agents, and remain easy to publish."
            , FeatureGridBlock
                [ feature "Promise first" "A good official site establishes what the product is in the first viewport instead of leading with internal process language."
                , feature "Path second" "Getting started, themes, publishability, and reference should feel like one coherent system, not a bag of related notes."
                , feature "Proof nearby" "Examples, release notes, and the public repo should be visible proof surfaces, but they should not crowd out the front door."
                , feature "Static output matters" "Routes, metadata, localized variants, and deploy files are part of the site product, not just packaging trivia."
                ]
            ]
        , namedSection
            "If your site fits"
            [ LinkGridBlock
                [ slugLinkCard "Start here" startSlug (Just "Build the smallest useful site and keep the public path coherent.")
                , slugLinkCard "Read the theme system" themeSlug (Just "Choose a visual voice and then tune it deliberately.")
                , slugLinkCard "Read publishability" publishabilitySlug (Just "Treat validation and deploy metadata as part of authoring.")
                , slugLinkCard "Read the reference" referenceSlug (Just "See the current module families and rules of use.")
                , collectionLinkCard "Browse the sample lab" labHomePath (Just "Compare Portico across multiple public-site shapes.")
                ]
            ]
        ])

  startPage =
    withSummary
      "The smallest path from one import to a publishable static site."
      (page
        startSlug
        (CustomKind "Start")
        "Start Here"
        [ namedSection
            "Golden path"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "Read the reference" referenceSlug (Just "See the current public module families before you drop into internals.")
                  , slugLinkCard "Read the theme system" themeSlug (Just "Choose a visual voice before you start hand-tuning design.")
                  , collectionLinkCard "Browse the sample lab" labHomePath (Just "Pressure-test the ideas on real public-site shapes.")
                  ]
                  (withEyebrow
                    "Authoring"
                    (hero
                      "Go from one import to a published site."
                      "Start from Portico, model the site semantically, choose an official theme, validate, and emit static output. The point is clarity, not ceremony.")))
            , TimelineBlock
                [ timelineEntry "Import from `Portico`" "Start from the umbrella module so site, theme, render, validate, and build stay on one obvious path." Nothing
                , timelineEntry "Model the site semantically" "Use site, page, section, semantic blocks, navigation, and route helpers instead of hand-writing layout fragments." Nothing
                , timelineEntry "Pick the official voice" "Start from officialTheme or a preset before tuning palette, spacing, typography, and surface details." Nothing
                , timelineEntry "Validate and emit" "Run validateSite, then render or emit clean static output once the site reads like a publishable surface." Nothing
                ]
            , CodeBlock
                (codeSample
                  gettingStartedCode
                  (Just "purescript")
                  (Just "A minimal Portico site"))
            ]
        , namedSection
            "Key APIs"
            [ FeatureGridBlock
                [ feature "Import from `Portico`" "Use the public root first. Drop into submodules only when the specific need is clear."
                , feature "`site`, `page`, and `namedSection`" "Keep the public information architecture visible in values instead of reconstructing it from layout markup."
                , feature "`officialThemeWith`" "Treat theme choice as a site-level decision and only then customize it in controlled layers."
                , feature "`validateSite` and `emitSite`" "Make diagnostics and static output part of the normal authoring loop, not last-minute cleanup."
                ]
            ]
        , namedSection
            "Next steps"
            [ LinkGridBlock
                [ slugLinkCard "Read the reference" referenceSlug (Just "Confirm the public module families and contract rules.")
                , slugLinkCard "Read publishability" publishabilitySlug (Just "See what Portico checks and emits before release.")
                , slugLinkCard "Read the AI workflow" aiPathSlug (Just "Keep delegated authoring aligned with the same narrow path.")
                , slugLinkCard "Read the theme system" themeSlug (Just "Learn how presets and layered overrides fit together.")
                , collectionLinkCard "Browse the sample lab" labHomePath (Just "Compare the library across multiple site categories.")
                ]
            ]
        ])

  aiPage =
    withSummary
      "A narrow authoring lane for implementation agents."
      (page
        aiPathSlug
        (CustomKind "AI")
        "AI Workflow"
        [ namedSection
            "Delegate the site, not the category"
            [ HeroBlock
                (withActions
                  [ linkCard "Read the agent quickstart" githubAgentQuickstartHref (Just "The repo-first operational path for building with Portico.")
                  , linkCard "Read the portico-user skill" githubSkillHref (Just "The adoption skill for wiring Portico into a consuming app.")
                  , slugLinkCard "Read publishability" publishabilitySlug (Just "Keep the release-facing checks inside the delegated workflow.")
                  ]
                  (withEyebrow
                    "Agent lane"
                    (hero
                      "Give implementation agents a narrow lane."
                      "Portico is intentionally shaped so a capable agent can stay on one public path: one import, semantic site primitives, official themes, validation, and static output.")))
            , FeatureGridBlock
                [ feature "One import path" "Agents should start from Portico, not from a scatter of low-level modules."
                , feature "Semantic primitives" "Reach for site, page, section, route helpers, and stable blocks before custom escape hatches."
                , feature "Route helpers, not raw hrefs" "Let the library keep relative links coherent as the output tree or mount path changes."
                , feature "Validation before publish" "Treat validateSite or validateLocalizedSite as a gate, not as optional polish."
                ]
            , CodeBlock
                (codeSample
                  aiChecklistCode
                  Nothing
                  (Just "Delegation checklist"))
            ]
        , namedSection
            "Protect these invariants"
            [ FeatureGridBlock
                [ feature "Clarify site kind first" "Official site, docs surface, release page, or editorial page should be explicit before implementation starts."
                , feature "Grow primitives when patterns repeat" "If the same shape keeps coming back, add a better domain primitive instead of scattering custom markup."
                , feature "Keep theme separate from content" "Design tokens and visual voice should not leak into the site model."
                , feature "Stay static-first" "Localization, metadata, and route structure should emit real pages before you consider runtime behavior."
                ]
            ]
        , namedSection
            "Follow-up links"
            [ LinkGridBlock
                [ slugLinkCard "Start here" startSlug (Just "Use the smallest useful path first.")
                , slugLinkCard "Read the reference" referenceSlug (Just "Keep the public surface in view while delegating.")
                , slugLinkCard "Read publishability" publishabilitySlug (Just "Make validation and deploy metadata part of the packet.")
                , collectionLinkCard "Browse the sample lab" labHomePath (Just "Compare the site model across multiple categories.")
                ]
            ]
        ])

  referencePage =
    withSummary
      "The current public Portico surface, contract rules, and docs map."
      (page
        referenceSlug
        Documentation
        "Reference"
        [ namedSection
            "Public surface"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "Start here" startSlug (Just "Read the smallest supported path before you dive into the full surface.")
                  , linkCard "Open GitHub" githubRepositoryHref (Just "See the current repo-first source of truth.")
                  , linkCard "Read architecture notes" githubArchitectureHref (Just "See how semantic core, theme, build, and validation are split.")
                  ]
                  (withEyebrow
                    "Current contract"
                    (hero
                      "These are the public modules today."
                      "Portico is still pre-beta, but the current public surface is already organized around one import path and a static-site workflow.")))
            , FeatureGridBlock
                [ feature "Portico.Site" "Site, page, section, block, navigation, locale, and publish-time metadata primitives."
                , feature "Portico.Build" "Static file emission helpers for single sites, mounted sites, and localized bundles."
                , feature "Portico.Render" "Pure rendering helpers for pages, full sites, and shared stylesheets."
                , feature "Portico.Validate" "Diagnostics for site structure, localization coverage, and publishability checks."
                , feature "Portico.Theme" "Theme tokens and layered customization helpers."
                , feature "Portico.Theme.Official" "Directional presets and officialThemeWith for controlled customization."
                ]
            ]
        , namedSection
            "Contract rules"
            [ FeatureGridBlock
                [ feature "Import from Portico" "Treat the umbrella module as the intended public entry point while the pre-beta surface settles."
                , feature "Prefer semantic blocks" "If a public-site pattern is recurring, model it semantically instead of dropping into layout fragments."
                , feature "Keep the theme separate" "Aesthetic direction belongs in the theme layer, not in the content model."
                , feature "Validate before release" "Make diagnostics part of the normal workflow before you publish or automate deployment."
                ]
            ]
        , namedSection
            "Docs map"
            [ LinkGridBlock
                [ linkCard "Vision" githubVisionHref (Just "Thesis, scope, and why Portico exists.")
                , linkCard "Architecture" githubArchitectureHref (Just "The semantic core, theme, build, validation, and optional-islands split.")
                , linkCard "Agent quickstart" githubAgentQuickstartHref (Just "The repo-first operational path for implementation agents.")
                , linkCard "Deployment guide" githubDeploymentHref (Just "GitHub Pages and base-url publishing flow.")
                , linkCard "Distribution note" githubDistributionHref (Just "Repo-first now, package distribution later.")
                , linkCard "Release checklist" githubReleaseChecklistHref (Just "Pre-beta release gate and publication checklist.")
                ]
            ]
        ])

  themePage =
    withSummary
      "How official presets and layered customization fit together."
      (page
        themeSlug
        Documentation
        "Theme System"
        [ namedSection
            "Choose a voice, then tune in layers"
            [ HeroBlock
                (withActions
                  [ collectionLinkCard "Open the preset catalog" presetCatalogPath (Just "Pick a theme by site intent before you fine-tune it.")
                  , collectionLinkCard "Browse the sample lab" labHomePath (Just "See the official themes applied to real sample surfaces.")
                  , slugLinkCard "Start here" startSlug (Just "Build one site before you widen the customization surface.")
                  ]
                  (withEyebrow
                    "Themes"
                    (hero
                      "Start from a voice, not from loose variables."
                      "Portico's official theme system gives you directional presets first, then controlled overrides for palette, typography, spacing, surface, radius, and shadow.")))
            , FeatureGridBlock
                [ feature "SignalPaper" "Calm default for docs and official project surfaces."
                , feature "CopperLedger" "Warmer, tighter voice for studio, portfolio, or case-study pages."
                , feature "NightCircuit" "Wider and darker for launch, technical announcement, or event-style surfaces."
                , feature "BlueLedger" "Narrower publication voice for notebooks, essays, and editorial reading."
                ]
            , CodeBlock
                (codeSample
                  themeCode
                  (Just "purescript")
                  (Just "Layered official-theme customization"))
            ]
        , namedSection
            "What changes cleanly"
            [ FeatureGridBlock
                [ feature "Accent or palette" "Nudge one brand color or swap in a full palette while staying on the official system."
                , feature "Typography" "Change display, body, and mono fonts without rewriting render markup."
                , feature "Spacing" "Change density, pacing, and rhythm at the theme-token layer."
                , feature "Surface and chrome" "Adjust frame width, pill shape, header treatment, and hero surface without leaking design into content values."
                ]
            , CalloutBlock
                (callout Quiet "The official site uses the same system" "Portico's own public site is emitted with the official theme system rather than with a one-off CSS stack outside the library.")
            ]
        , namedSection
            "See it on real sites"
            [ LinkGridBlock
                [ collectionLinkCard "Preset catalog" presetCatalogPath (Just "Compare presets and customization paths from one chooser page.")
                , collectionLinkCard "Northline Docs" docsSamplePath (Just "See the calmer docs-facing voice in a sample surface.")
                , collectionLinkCard "Northstar Cloud" productSamplePath (Just "See a stronger product-landing interpretation of the official system.")
                , collectionLinkCard "Mina Arai" profileSamplePath (Just "See the system adapted to a profile and case-study surface.")
                , collectionLinkCard "Signal Summit" summitSamplePath (Just "See the darker event-oriented voice in practice.")
                ]
            ]
        ])

  publishabilityPage =
    withSummary
      "Validation, metadata, localization, and deploy-oriented output for publishable static sites."
      (page
        publishabilitySlug
        Documentation
        "Publish"
        [ namedSection
            "Publish like a site, not a bundle"
            [ HeroBlock
                (withActions
                  [ linkCard "Read the deployment guide" githubDeploymentHref (Just "See the GitHub Pages-oriented publishing path.")
                  , slugLinkCard "Read release 0.1.0" releaseSlug (Just "See the current shipped slice and what is still moving.")
                  , slugLinkCard "Read the AI workflow" aiPathSlug (Just "Keep delegated authoring and release checks aligned.")
                  ]
                  (withEyebrow
                    "Publishability"
                    (hero
                      "Treat publishability as part of authoring."
                      "Routes, summaries, metadata, locale variants, and static host output are part of the site product. Portico keeps them inside the same authoring loop instead of leaving them to a separate cleanup phase.")))
            , FeatureGridBlock
                [ feature "Structure and route checks" "Catch missing index pages, duplicate paths, duplicate section ids, and broken internal site links."
                , feature "Content-quality checks" "Warn when summaries are missing or when navigation and link-card labels are left empty."
                , feature "Metadata and locale output" "Derive canonical URLs, social metadata, lang, and hreflang from the site model."
                , feature "Deploy-oriented files" "Emit shared CSS, 404.html, robots.txt, sitemap.xml, and localized static routes for Pages-style hosting."
                ]
            , TimelineBlock
                [ timelineEntry "Model the site" "Keep public structure, metadata, and locale variants in the site definition itself." Nothing
                , timelineEntry "Validate" "Use validateSite or validateLocalizedSite before you treat the site as release-ready." Nothing
                , timelineEntry "Render and emit" "Generate clean output paths, shared stylesheets, relative links, and static assets." Nothing
                , timelineEntry "Deploy" "Add a base URL, build pages output, and publish with a static host such as GitHub Pages." Nothing
                ]
            ]
        , namedSection
            "Localized static output"
            [ CodeBlock
                (codeSample
                  localizedCode
                  (Just "purescript")
                  (Just "Localized static publishing"))
            , FaqBlock
                [ faqEntry "Do I need a base URL to render?" "No. Base URLs matter when you want canonical or social URLs and deploy-oriented output such as sitemap.xml. Rendering and relative links still work without one."
                , faqEntry "Can Portico localize a static site?" "Yes. The supported path is static-first: emit real locale variants as real pages, keep language switching link-based, and let the build layer handle lang and alternate metadata."
                , faqEntry "Is Portico trying to be a static CMS?" "No. The target is authored static surfaces with strong information architecture, not a content-management product."
                , faqEntry "Does publishability stop at HTML?" "No. The build story also covers CSS assets, canonical and social metadata, localized alternates, and static-host helper files."
                ]
            ]
        , namedSection
            "Next"
            [ LinkGridBlock
                [ slugLinkCard "Read the reference" referenceSlug (Just "See the current public modules behind the publish path.")
                , slugLinkCard "Read the AI workflow" aiPathSlug (Just "Keep delegated work aligned with validation and deploy concerns.")
                , linkCard "Read the deployment guide" githubDeploymentHref (Just "Follow the GitHub Pages-oriented publishing flow.")
                , collectionLinkCard "Browse the sample lab" labHomePath (Just "See the output story across multiple public-site shapes.")
                ]
            ]
        ])

  releasePage =
    withSummary
      "The first practical Portico slice."
      (page
        releaseSlug
        ReleaseNotes
        "Release 0.1.0"
        [ namedSection
            "Current release"
            [ HeroBlock
                (withActions
                  [ linkCard "Open GitHub" githubRepositoryHref (Just "Read the repo, changelog, and current issues.")
                  , collectionLinkCard "Browse the sample lab" labHomePath (Just "See the broader proof surface that pressures the library.")
                  , linkCard "Read the distribution note" githubDistributionHref (Just "See the repo-first posture and why package release is later.")
                  ]
                  (withEyebrow
                    "Status"
                    (hero
                      "Portico is in public pre-beta."
                      "The semantic site model, official theme system, validation layer, localized output, and GitHub Pages-oriented build path are all live now. Package distribution and the final public contract are still being tightened.")))
            , FeatureGridBlock
                [ feature "Semantic site DSL" "Site, page, section, navigation, metadata, and pressure-tested block primitives for public surfaces."
                , feature "Official theme system" "Directional presets plus layered customization for palette, typography, spacing, and chrome."
                , feature "Publishability and build" "Validation, canonical and social metadata, localized bundles, and Pages-style output are already in the repo."
                , feature "Dogfooded proof surface" "The official site and mounted sample lab are both emitted by Portico and used as the main public onboarding surface."
                ]
            , CalloutBlock
                (callout Strong "What this release means" "Portico is ready for serious evaluation from a local checkout. It is not yet promising registry-grade stability or packaging.")
            ]
        , namedSection
            "What shipped"
            [ FeatureGridBlock
                [ feature "Static-site fundamentals" "Relative links, shared CSS, assets, canonical metadata, and static file emission."
                , feature "Localized publishing" "English and Japanese official-site variants emitted from one localized bundle with alternate metadata."
                , feature "Validator baseline" "Checks for path collisions, broken routes, weak summaries, misplaced heroes, and other publishability concerns."
                , feature "Pressure-test gallery" "Six generated sample sites plus a preset catalog used to expose gaps in the model."
                ]
            ]
        , namedSection
            "Next"
            [ FeatureGridBlock
                [ feature "Richer validators" "Extend diagnostics beyond the first publishability baseline so release review carries more confidence."
                , feature "A stronger asset story" "Move beyond one shared stylesheet toward a fuller publish-time asset model."
                , feature "Sharper official themes" "Keep strengthening the defaults so Portico sites look intentional before customization."
                , feature "More pressure from the lab" "Keep adding samples and refinements that expose weak spots in the site vocabulary."
                ]
            , LinkGridBlock
                [ linkCard "Read the release checklist" githubReleaseChecklistHref (Just "The current pre-beta release gate and publication checklist.")
                , linkCard "Read the distribution note" githubDistributionHref (Just "Why the project is repo-first today and package-first later.")
                , slugLinkCard "Read publishability" publishabilitySlug (Just "The validation and deploy-facing side of the current release.")
                , slugLinkCard "Read the theme system" themeSlug (Just "The design layer that still needs the most visible strengthening.")
                ]
            ]
        ])

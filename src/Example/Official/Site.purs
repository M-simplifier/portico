module Example.Official.Site
  ( officialSite
  ) where

import Prelude

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
  , linkCard
  , namedSection
  , navItem
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
    [ slugNavItem "Learn" learnSlug
    , slugNavItem "Start" startSlug
    , slugNavItem "AI" aiPathSlug
    , slugNavItem "Reference" referenceSlug
    , collectionNavItem "Lab" labHomePath
    , navItem "GitHub" githubRepositoryHref
    ]
      (withDescription
      "Semantic PureScript sites for docs, releases, portfolios, essays, and other published static surfaces."
      (site
        "Portico"
        [ homePage
        , learnPage
        , startPage
        , aiPathPage
        , referencePage
        , themePage
        , publishabilityPage
        , releasePage
        ]))
  where
  learnSlug = "learn/fit"

  startSlug = "guide/getting-started"

  aiPathSlug = "guide/ai-path"

  referenceSlug = "reference/public-surface"

  themeSlug = "guide/theme-system"

  publishabilitySlug = "guide/publishability"

  releaseSlug = "releases/0-1-0"

  labHomePath = "lab/index.html"

  presetCatalogPath = "lab/presets.html"

  githubRepositoryHref = "https://github.com/M-simplifier/portico"

  githubAgentQuickstartHref = githubRepositoryHref <> "/blob/main/docs/agent-quickstart.md"

  githubSkillHref = githubRepositoryHref <> "/blob/main/skills/portico-user/SKILL.md"

  githubDeploymentHref = githubRepositoryHref <> "/blob/main/docs/deployment.md"

  githubDistributionHref = githubRepositoryHref <> "/blob/main/docs/distribution.md"

  githubReleaseChecklistHref = githubRepositoryHref <> "/blob/main/docs/release-checklist.md"

  homePage =
    withSummary
      "A semantic site DSL, official theme system, and publishability path for published static sites in PureScript."
      (page
        "index"
        Landing
        "Portico"
        [ namedSection
            "Overview"
            [ HeroBlock
                (withActions
                  [ slugLinkCard "Learn where Portico fits" learnSlug (Just "Decide whether Portico matches the kind of public site you need to publish.")
                  , slugLinkCard "Start with the supported path" startSlug (Just "Go from one import to validated static output.")
                  , slugLinkCard "See the AI path" aiPathSlug (Just "Use the narrow, repo-first path intended for high-agency implementation agents.")
                  ]
                  (withEyebrow
                    "Published static sites"
                    (hero
                      "Build published static sites in PureScript."
                      "Portico gives docs, release pages, portfolios, essays, and other public surfaces a semantic site model, an official theme system, and a static publishability path. It is not a lighter Asterism, and it is not aimed at app-shell software.")))
            , FeatureGridBlock
                [ feature "Semantic site model" "Keep public information architecture explicit in `site`, `page`, `section`, and blocks instead of burying it in ad hoc layout markup."
                , feature "Official theme system" "Start from reading posture rather than accent color, then customize in layers without collapsing the site model."
                , feature "Publishability by default" "Validate routes, summaries, metadata, and output shape before treating a site definition as real."
                , feature "Repo-first truth" "The official site, sample lab, and repo docs are the current contract while pre-beta work is still moving."
                ]
            ]
        , namedSection
            "Choose your path"
            [ LinkGridBlock
                [ slugLinkCard "Learn where it fits" learnSlug (Just "Start with category fit, scope, and the Portico vs Asterism boundary.")
                , slugLinkCard "Get started" startSlug (Just "Move from one import to a minimal validated site.")
                , slugLinkCard "Use it with AI" aiPathSlug (Just "Review the operational path for delegating site work to an implementation agent.")
                , slugLinkCard "Read the reference" referenceSlug (Just "See the supported families, contract rules, and docs map.")
                ]
            ]
        , namedSection
            "See it in practice"
            [ CalloutBlock
                (callout Quiet "Optional proof" "Once the fit and supported path are clear, use the sample lab and preset catalog to pressure-test breadth and visual range.")
            , LinkGridBlock
                [ collectionLinkCard "Browse the sample lab" labHomePath (Just "Explore the broader pressure-test gallery across docs, product, portfolio, profile, event, and publication surfaces.")
                , collectionLinkCard "Open the preset catalog" presetCatalogPath (Just "Choose a theme by site intent and reading posture before fine-grained customization.")
                , slugLinkCard "Deep dive on themes" themeSlug (Just "See how presets and layered customization fit together.")
                , slugLinkCard "Deep dive on publishability" publishabilitySlug (Just "Review validation, metadata, static output, and deploy-oriented files.")
                ]
            ]
        , namedSection
            "Current release"
            [ CalloutBlock
                (callout Quiet "Pre-beta, repo-first" "Portico is public and usable now, but the contract is still settling. Treat the repository, official site, and `npm run verify` as the current source of truth.")
            , LinkGridBlock
                [ slugLinkCard "Read release 0.1.0" releaseSlug (Just "See what is live now and what is still intentionally moving.")
                , linkCard "Open the GitHub repository" githubRepositoryHref (Just "Use the repo as the current source of truth for code, docs, issues, and release posture.")
                , linkCard "Read the deployment guide" githubDeploymentHref (Just "Review the GitHub Pages-oriented base-URL and publish flow.")
                ]
            ]
        ])

  learnPage =
    withSummary
      "Decide whether Portico matches the kind of site you need to publish."
      (page
        learnSlug
        (CustomKind "Learn")
        "What Portico Is For"
        [ namedSection
            "Category"
            [ ProseBlock "Portico is for published public surfaces: official project sites, docs, release pages, portfolios, essays, and small event or campaign sites that should ship cleanly as static output."
            , FeatureGridBlock
                [ feature "Official sites" "Use Portico when a project needs a public front door, a stable explanation path, and a readable release surface."
                , feature "Docs and guides" "Use it for concept pages, getting-started flows, API-adjacent reference, and release adjacency without turning the site into an app shell."
                , feature "Release and publication surfaces" "Portico fits changelog pages, essays, notebooks, and other reading-first artifacts with a public publishing cadence."
                , feature "Portfolios and microsites" "It also fits calmer showcase, case-study, and event-style sites where public information architecture matters more than interaction density."
                ]
            , CalloutBlock
                (callout Strong "Not a lighter Asterism" "If the surface wants long-lived state, authenticated flows, heavy interaction, or browser-software behavior, the design center has already shifted out of Portico.")
            ]
        , namedSection
            "How Portico thinks"
            [ FeatureGridBlock
                [ feature "Semantic structure first" "The public model starts from site, page, section, block, navigation, and route helpers instead of raw HTML fragments."
                , feature "Theme stays separate" "Design tokens, reading posture, spacing, and chrome live in the theme layer rather than leaking into the content model."
                , feature "Static-first build" "Rendering, validation, metadata, and file emission are all aimed at clean static output rather than app runtime concerns."
                , feature "Public IA over interaction" "The center of gravity is explanation, sequencing, and orientation on public surfaces, not micro-interaction density."
                ]
            , CalloutBlock
                (callout Accent "Why this matters" "The goal is to let humans and AI land on the same explicit public-site structure instead of rediscovering it from layout markup every time.")
            ]
        , namedSection
            "What it is not for"
            [ FeatureGridBlock
                [ feature "Dashboards" "Operational consoles want dense state, filters, and interaction loops that are outside Portico's center of gravity."
                , feature "Editors" "Authoring and editing software need a different runtime model than publish-time static output."
                , feature "Authenticated apps" "If identity, sessions, and private state are core to the surface, Portico is the wrong abstraction boundary."
                , feature "Interaction-heavy browser software" "Once a site starts acting like software first and a public surface second, the problem should likely move toward Asterism."
                ]
            ]
        , namedSection
            "If it fits"
            [ LinkGridBlock
                [ slugLinkCard "Start with the supported path" startSlug (Just "Move from fit into the minimal authoring path.")
                , slugLinkCard "See the AI path" aiPathSlug (Just "Review the repo-first, agent-oriented adoption lane.")
                , slugLinkCard "Read the reference" referenceSlug (Just "Confirm the supported families and contract rules.")
                , slugLinkCard "Review the theme system" themeSlug (Just "Pick a preset and only then customize in layers.")
                , slugLinkCard "Review publishability" publishabilitySlug (Just "See the validation and static-output side of the contract.")
                , collectionLinkCard "Browse the sample lab" labHomePath (Just "Use the broader proof surface after the fit is clear.")
                ]
            ]
        ])

  startPage =
    withSummary
      "The shortest supported path from one import to validated static output."
      (page
        startSlug
        (CustomKind "Start")
        "Get Started"
        [ namedSection
            "Golden path"
            [ TimelineBlock
                [ timelineEntry "1. Import from `Portico`" "Start from the root module so the supported site, theme, render, validate, and build families stay on one obvious path." Nothing
                , timelineEntry "2. Model the site semantically" "Use `site`, `page`, `section`, semantic blocks, navigation, and route helpers instead of raw HTML fragments." Nothing
                , timelineEntry "3. Choose the official voice" "Start from `officialTheme` or an official preset before reaching for custom typography, spacing, or surface overrides." Nothing
                , timelineEntry "4. Validate and emit" "Run `validateSite`, then render or emit static output once the public surface is coherent." Nothing
                ]
            , CalloutBlock
                (callout Accent "Stay on the supported path" "If a shape keeps recurring, add or refine a Portico primitive instead of scattering one-off markup.")
            ]
        , namedSection
            "Minimal site"
            [ CodeBlock
                (codeSample
                  "import Portico\n\nsiteDefinition =\n  site \"Signal Manual\"\n    [ withSummary\n        \"A calm docs front door.\"\n        (page \"index\" Landing \"Signal Manual\"\n          [ namedSection \"Intro\"\n              [ HeroBlock\n                  (hero\n                    \"Published surfaces in PureScript.\"\n                    \"Stay on the semantic path.\")\n              ]\n          ])\n    ]\n\nmain = do\n  let report = validateSite siteDefinition\n  emitSite \"site/dist\" officialTheme siteDefinition"
                  (Just "purescript")
                  (Just "One import, one site, one validated build path"))
            ]
        , namedSection
            "Reach for these first"
            [ FeatureGridBlock
                [ feature "Import from `Portico`" "Start from the umbrella module before you drop into individual families."
                , feature "`officialTheme`" "Use the calm default first, then move to presets or layered customization only when the site needs it."
                , feature "`validateSite`" "Treat publishability diagnostics as part of the supported authoring loop, not as optional polish."
                , feature "`emitSite` / `emitMountedSite`" "Emit clean static output once the site structure and relative paths are ready."
                ]
            ]
        , namedSection
            "Next docs"
            [ LinkGridBlock
                [ slugLinkCard "Read the reference" referenceSlug (Just "See the supported families and contract rules.")
                , slugLinkCard "Review the AI path" aiPathSlug (Just "Use the narrower adoption lane when the work is being delegated to an agent.")
                , slugLinkCard "Review the theme system" themeSlug (Just "Choose a preset and understand the customization ladder.")
                , slugLinkCard "Review publishability" publishabilitySlug (Just "See what Portico checks and emits before publish.")
                , collectionLinkCard "Browse the sample lab" labHomePath (Just "Compare the broader pressure-test surfaces after the minimal path is clear.")
                ]
            ]
        ])

  aiPathPage =
    withSummary
      "The operational lane for people deciding whether to delegate site authoring to AI."
      (page
        aiPathSlug
        (CustomKind "AI Path")
        "AI Adoption Path"
        [ namedSection
            "Delegation"
            [ HeroBlock
                (withActions
                  [ linkCard "Open Agent Quickstart" githubAgentQuickstartHref (Just "Read the repo doc that describes the default AI-oriented implementation path.")
                  , slugLinkCard "Read the public surface" referenceSlug (Just "Confirm the supported families and contract rules before broadening the task.")
                  , linkCard "Open the repo-first skill" githubSkillHref (Just "See the source-first adoption skill for consuming apps before package distribution.")
                  ]
                  (withEyebrow
                    "AI-native lane"
                    (hero
                      "Portico is designed to be delegated cleanly."
                      "Most people evaluating Portico are deciding whether an implementation agent can use it correctly. The supported path is intentionally narrow: one import, semantic site primitives, official themes, validation, and static output.")))
            ]
        , namedSection
            "Supported operating shape"
            [ FeatureGridBlock
                [ feature "One import path" "Agents should start from `Portico`, not from scattered low-level modules."
                , feature "Semantic primitives" "The authoring surface names site roles directly, which reduces drift into raw layout markup."
                , feature "Official theme path" "A strong default plus explicit presets lowers aesthetic ambiguity for delegated work."
                , feature "Validation before publish" "Agents can check routes, summaries, and structure before they treat output as acceptable."
                , feature "Static build path" "Render and file emission stay deterministic and subpath-safe for public hosting."
                , feature "Repo-first adoption" "Today the safest adoption path is still source-first, with explicit docs and a visible public surface."
                ]
            ]
        , namedSection
            "What to tell the agent"
            [ CodeBlock
                (codeSample
                  "Use Portico for a published static site.\nImport from Portico.\nStay on semantic site primitives.\nKeep theme concerns separate from the content model.\nUse officialTheme or officialThemeWith*.\nRun validateSite before publish.\nEmit static output with emitSite or emitMountedSite."
                  (Just "text")
                  (Just "Minimal task packet for an implementation agent"))
            , CalloutBlock
                (callout Quiet "Pre-beta posture" "Keep the adoption path repo-first for now: local checkout, explicit public surface, and verification in the consuming workspace.")
            ]
        , namedSection
            "Operational references"
            [ LinkGridBlock
                [ linkCard "Agent Quickstart" githubAgentQuickstartHref (Just "Repo doc for the default AI-oriented implementation path.")
                , linkCard "portico-user skill" githubSkillHref (Just "Repo-first adoption skill for wiring Portico into a consuming app.")
                , slugLinkCard "Public Surface" referenceSlug (Just "The supported families and contract rules on the official site.")
                , slugLinkCard "Publishability" publishabilitySlug (Just "The validation, metadata, and static-output side of the contract.")
                , linkCard "Distribution note" githubDistributionHref (Just "The current repo-first posture and package-later distribution story.")
                , linkCard "Open GitHub" githubRepositoryHref (Just "Use the public repository as the live source of truth.")
                ]
            ]
        ])

  referencePage =
    withSummary
      "The current supported Portico surface, contract rules, and docs map."
      (page
        referenceSlug
        (CustomKind "Reference")
        "Public Surface"
        [ namedSection
            "Supported families"
            [ FeatureGridBlock
                [ feature "Portico.Site" "Site, page, section, block, navigation, link, and publish-time metadata primitives."
                , feature "Portico.Build" "Static file emission helpers such as `emitSite` and `emitMountedSite`."
                , feature "Portico.Render" "Pure rendering helpers such as `renderSite`, `renderStaticSite`, `renderPage`, and `renderStylesheet`."
                , feature "Portico.Validate" "Publishability diagnostics such as `validateSite`, `siteDiagnostics`, and `hasErrors`."
                , feature "Portico.Theme" "Theme tokens and layered customization helpers."
                , feature "Portico.Theme.Official" "Official presets and the `officialThemeWith*` customization path."
                ]
            ]
        , namedSection
            "Contract rules"
            [ FeatureGridBlock
                [ feature "Import from `Portico`" "Treat the umbrella module as the intended public entry point while the pre-beta surface settles."
                , feature "Prefer semantic primitives" "Add or refine domain blocks instead of scattering raw markup when a pattern repeats."
                , feature "Keep theme separate" "Aesthetic choices belong in the theme layer, not in the page model."
                , feature "Prefer route helpers" "Use site and collection helpers instead of hand-writing internal relative paths."
                , feature "Run `validateSite`" "Treat publishability diagnostics as part of the supported workflow before release."
                ]
            ]
        , namedSection
            "Docs map"
            [ LinkGridBlock
                [ slugLinkCard "Learn where it fits" learnSlug (Just "Category fit, scope, and the Portico vs Asterism boundary.")
                , slugLinkCard "Get started" startSlug (Just "The shortest supported path from import to emitted output.")
                , slugLinkCard "AI adoption path" aiPathSlug (Just "The narrower repo-first lane for delegated implementation.")
                , slugLinkCard "Theme system" themeSlug (Just "Preset selection and layered customization.")
                , slugLinkCard "Publishability" publishabilitySlug (Just "Validation, metadata, static output, and deploy-oriented files.")
                , slugLinkCard "Release 0.1.0" releaseSlug (Just "What is live now and what is still moving.")
                , collectionLinkCard "Sample lab" labHomePath (Just "Broader proof across docs, product, portfolio, profile, event, and publication surfaces.")
                , linkCard "Deployment guide" githubDeploymentHref (Just "GitHub Pages-oriented build and base-URL flow.")
                , linkCard "Release checklist" githubReleaseChecklistHref (Just "The current repo-first publication checklist and gate.")
                ]
            ]
        , namedSection
            "Still moving"
            [ CalloutBlock
                (callout Quiet "Pre-beta contract" "The exact block vocabulary, validator depth, asset story beyond the first stylesheet, and the long-term package split are all still expected to move during pre-beta.")
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
            "How to choose"
            [ ProseBlock "Start from site intent and reading posture before you start thinking about accent color. The official system is meant to stay opinionated enough to produce strong public surfaces quickly."
            , FeatureGridBlock
                [ feature "Start from intent" "Choose docs, studio, launch, or publication posture before you start tuning color or typography."
                , feature "Customize in layers" "Accent, palette, typography, spacing, surface, radius, and shadow sit on top of the official system instead of replacing it."
                , feature "Keep the DSL semantic" "Theme detail belongs in the theme layer, not in the page model."
                ]
            ]
        , namedSection
            "Official presets"
            [ FeatureGridBlock
                [ feature "SignalPaper" "Calm default for official docs and project surfaces."
                , feature "CopperLedger" "Tighter, warmer studio or portfolio voice."
                , feature "NightCircuit" "Wider, darker technical launch or event voice."
                , feature "BlueLedger" "Narrower publication or notebook voice."
                ]
            ]
        , namedSection
            "Customization ladder"
            [ CodeBlock
                (codeSample
                  "import Portico\n\nlaunchTheme =\n  officialThemeWith\n    ((officialThemeOptions SignalPaper)\n      { accent = Just \"#0f766e\"\n      , spacing = Just\n          { pageInset: \"3.2rem\"\n          , pageTop: \"4.7rem\"\n          , pageBottom: \"5.6rem\"\n          , sectionGap: \"3.2rem\"\n          , stackGap: \"1.3rem\"\n          , cardPadding: \"1.4rem\"\n          , heroPadding: \"2.35rem\"\n          }\n      })"
                  (Just "purescript")
                  (Just "One code-first entry point for official-theme customization"))
            , CalloutBlock
                (callout Quiet "Optional proof" "Use the preset catalog after the site category is already clear. It is supporting proof, not the first decision point.")
            , LinkGridBlock
                [ collectionLinkCard "Browse the preset catalog" presetCatalogPath (Just "See the presets mapped to generated sample surfaces.")
                , collectionLinkCard "Compare the sample lab" labHomePath (Just "Pressure-test the official theme system across multiple site categories.")
                , slugLinkCard "Return to start" startSlug (Just "Keep the supported authoring path in view while choosing a theme.")
                , slugLinkCard "Return to reference" referenceSlug (Just "Re-check the supported surface while you customize.")
                ]
            ]
        ])

  publishabilityPage =
    withSummary
      "Validation, build output, and deploy-oriented metadata for public surfaces."
      (page
        publishabilitySlug
        Documentation
        "Publishability"
        [ namedSection
            "What Portico checks"
            [ FeatureGridBlock
                [ feature "Validator first" "Check for missing index pages, duplicate paths, broken internal routes, weak summaries, and misplaced heroes before publish."
                , feature "Metadata from the model" "Canonical, OG, and Twitter tags are derived from site and page values instead of raw head markup."
                , feature "Static output" "Emit files that stay subpath-safe under nested routes, shared CSS assets, and mounted collections."
                , feature "Pages-ready files" "GitHub Pages-style output can include `404.html`, `robots.txt`, and `sitemap.xml` without polluting the semantic site DSL."
                ]
            ]
        , namedSection
            "Build sequence"
            [ TimelineBlock
                [ timelineEntry "Render" "Use `renderSite` for quick inspection or inline previews while the page model is still moving." Nothing
                , timelineEntry "Validate" "Use `validateSite` as the publishability gate before treating a site definition as release-ready." Nothing
                , timelineEntry "Emit" "Use `emitSite` or `emitMountedSite` once the surface is ready for static hosting output." Nothing
                , timelineEntry "Publish" "Add a base URL and deploy-oriented files once the site is meant to behave like a real public artifact." Nothing
                ]
            , CodeBlock
                (codeSample
                  "import Portico\n\nreport = validateSite siteDefinition\nsiteHasErrors = hasErrors siteDefinition\n\nmain =\n  emitSite \"site/dist\" officialTheme siteDefinition"
                  (Just "purescript")
                  (Just "Validation before emission"))
            ]
        , namedSection
            "Common questions"
            [ FaqBlock
                [ faqEntry "Do I need a base URL to render?" "No. Base URLs matter when you want canonical and social metadata, not when you are still previewing locally."
                , faqEntry "Should I hand-write relative links?" "Prefer route helpers and mounted collection helpers so nested output stays coherent."
                , faqEntry "What is the release-oriented repo check?" "Use `npm run verify`. It composes tests with standalone sample-lab, official-site, and GitHub Pages-style build output."
                , faqEntry "Is Portico trying to be a static CMS?" "No. The target is authored static surfaces with strong information architecture, not content-management tooling."
                ]
            ]
        , namedSection
            "Deploy-oriented docs"
            [ LinkGridBlock
                [ slugLinkCard "Read the reference" referenceSlug (Just "Return to the supported families and contract rules.")
                , slugLinkCard "Read the AI path" aiPathSlug (Just "Keep the delegated authoring path aligned with the publishability contract.")
                , linkCard "Read the deployment guide" githubDeploymentHref (Just "Review the GitHub Pages-oriented build and base-URL flow.")
                , linkCard "Read the release checklist" githubReleaseChecklistHref (Just "See the repo-first publication gate and checklist.")
                ]
            ]
        ])

  releasePage =
    withSummary
      "The first working slice of Portico."
      (page
        releaseSlug
        ReleaseNotes
        "Release 0.1.0"
        [ namedSection
            "What is live now"
            [ FeatureGridBlock
                [ feature "Typed site model" "Site, page, section, navigation, route, and block vocabulary are already in place for published static surfaces."
                , feature "Official theme system" "The official preset path, layered customization, and preset catalog are all live."
                , feature "Publishability and build" "Validation, canonical/social metadata, static emission, and GitHub Pages-style output are already part of the repo-first slice."
                , feature "Mounted proof surface" "The official site and broader sample lab now ship side by side as the public onboarding surface."
                ]
            ]
        , namedSection
            "Current posture"
            [ CalloutBlock
                (callout Strong "Status" "Portico is in public pre-beta. The official site, repo docs, sample lab, validation path, and GitHub Pages build are live, while package distribution and final contract details are still moving.")
            ]
        , namedSection
            "Still moving"
            [ FeatureGridBlock
                [ feature "Block vocabulary" "The exact semantic block set will keep being pressure-tested against real public-site shapes."
                , feature "Validator depth" "Diagnostics coverage will keep expanding beyond the first publishability pass."
                , feature "Asset story" "The path beyond the first shared stylesheet and mounted sample assets is still intentionally open."
                , feature "Package split" "The long-term registry packaging and package metadata are still intentionally deferred."
                ]
            ]
        , namedSection
            "Next moves"
            [ LinkGridBlock
                [ slugLinkCard "Learn where it fits" learnSlug (Just "Return to the category and scope framing.")
                , slugLinkCard "Start with the supported path" startSlug (Just "Move from release posture into the concrete authoring path.")
                , collectionLinkCard "Browse the sample lab" labHomePath (Just "Use the pressure-test surfaces to see where the model still needs work.")
                , linkCard "Open GitHub" githubRepositoryHref (Just "Track code, issues, docs, and the current pre-beta posture in the public repo.")
                ]
            ]
        ])

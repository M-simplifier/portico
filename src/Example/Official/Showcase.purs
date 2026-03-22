module Example.Official.Showcase
  ( SampleSite
  , ShowcasePaths
  , buildMountedShowcase
  , buildMountedShowcaseWithSiteTransform
  , buildShowcase
  , mountedShowcasePaths
  , sampleSitesWithPaths
  , sampleSites
  , showcaseOutputDirectory
  , showcaseSiteWithPaths
  , showcaseSite
  ) where

import Prelude

import Data.Array (filter)
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..))
import Example.Official.Artwork (minaPortraitSvg, northstarDiagramSvg)
import Example.Official.FileSystem (removeTree)
import Effect (Effect)
import Portico
  ( Block(..)
  , CalloutTone(..)
  , LinkCard
  , NavItem
  , OfficialPreset(..)
  , Page
  , PageKind(..)
  , Section
  , Site
  , Theme
  , callout
  , collectionNavItem
  , collectionLinkCard
  , emitRenderedAsset
  , codeSample
  , emitMountedSite
  , emitSite
  , faqEntry
  , feature
  , hero
  , officialThemeWith
  , officialThemeOptions
  , officialThemeWithPalette
  , officialThemeWithPreset
  , siteImage
  , metric
  , namedSection
  , officialTheme
  , page
  , quote
  , person
  , site
  , slugLinkCard
  , slugNavItem
  , timelineEntry
  , withCaption
  , withActions
  , withDescription
  , withEyebrow
  , withNavigation
  , withSectionId
  , withSummary
  )

type SampleSite =
  { slug :: String
  , label :: String
  , summary :: String
  , theme :: Theme
  , site :: Site
  , assets :: Array { path :: String, content :: String }
  }

type SampleDirectoryEntry =
  { slug :: String
  , label :: String
  , summary :: String
  }

type ThemeGuideEntry =
  { label :: String
  , path :: String
  , summary :: String
  }

type ShowcasePaths =
  { labHomePath :: String
  , officialHomePath :: Maybe String
  }

showcaseOutputDirectory :: String
showcaseOutputDirectory = "examples/official/dist"

buildShowcase :: String -> Effect Unit
buildShowcase outputDirectory = do
  removeTree outputDirectory
  emitSite outputDirectory showcaseTheme showcaseSite
  emitSampleSites outputDirectory sampleSites

buildMountedShowcase :: String -> String -> Effect Unit
buildMountedShowcase =
  buildMountedShowcaseWithSiteTransform identity

buildMountedShowcaseWithSiteTransform :: (Site -> Site) -> String -> String -> Effect Unit
buildMountedShowcaseWithSiteTransform siteTransform outputDirectory mountPath = do
  let
    paths = mountedShowcasePaths mountPath
  emitMountedSite outputDirectory mountPath showcaseTheme (siteTransform (showcaseSiteWithPaths paths))
  emitSampleSites outputDirectory (map (mapSampleSite siteTransform) (sampleSitesWithPaths paths))

emitSampleSites :: String -> Array SampleSite -> Effect Unit
emitSampleSites outputDirectory currentSampleSites =
  traverse_ emitSample currentSampleSites
  where
  emitSample sampleSite = do
    emitMountedSite outputDirectory ("samples/" <> sampleSite.slug) sampleSite.theme sampleSite.site
    traverse_ (emitRenderedAsset outputDirectory) sampleSite.assets

mapSampleSite :: (Site -> Site) -> SampleSite -> SampleSite
mapSampleSite siteTransform sampleSite =
  sampleSite { site = siteTransform sampleSite.site }

rootShowcasePaths :: ShowcasePaths
rootShowcasePaths =
  { labHomePath: "index.html"
  , officialHomePath: Nothing
  }

mountedShowcasePaths :: String -> ShowcasePaths
mountedShowcasePaths mountPath =
  { labHomePath: mountedIndexPath mountPath
  , officialHomePath:
      if mountPath == "" then
        Nothing
      else
        Just "index.html"
  }

docsSample :: SampleDirectoryEntry
docsSample =
  { slug: "northline-docs"
  , label: "Northline Docs"
  , summary: "A calm docs surface with concepts, reference, and release adjacency."
  }

northstarSample :: SampleDirectoryEntry
northstarSample =
  { slug: "northstar-cloud"
  , label: "Northstar Cloud"
  , summary: "A product landing surface with proof, rollout framing, and customer voice."
  }

atelierSample :: SampleDirectoryEntry
atelierSample =
  { slug: "atelier-north"
  , label: "Atelier North"
  , summary: "A portfolio and case-study surface that leans on metrics and milestones."
  }

minaSample :: SampleDirectoryEntry
minaSample =
  { slug: "mina-arai"
  , label: "Mina Arai"
  , summary: "A profile and case-study hybrid for an independent design engineer."
  }

summitSample :: SampleDirectoryEntry
summitSample =
  { slug: "signal-summit"
  , label: "Signal Summit"
  , summary: "An event microsite with a schedule-heavy information shape."
  }

journalSample :: SampleDirectoryEntry
journalSample =
  { slug: "field-notes"
  , label: "Field Notes"
  , summary: "A small publication surface with issue navigation and essay pacing."
  }

sampleDirectory :: Array SampleDirectoryEntry
sampleDirectory =
  [ docsSample
  , northstarSample
  , atelierSample
  , minaSample
  , summitSample
  , journalSample
  ]

officialPresetGuides :: Array ThemeGuideEntry
officialPresetGuides =
  [ { label: "SignalPaper"
    , path: sampleIndexPath docsSample
    , summary: "Calm default for docs and official project surfaces. See it on Northline Docs."
    }
  , { label: "CopperLedger"
    , path: sampleIndexPath atelierSample
    , summary: "Tighter, warmer studio or portfolio voice. See it on Atelier North."
    }
  , { label: "NightCircuit"
    , path: sampleIndexPath summitSample
    , summary: "Wider, darker technical launch or event voice. See it on Signal Summit."
    }
  , { label: "BlueLedger"
    , path: sampleIndexPath journalSample
    , summary: "Narrower publication or notebook voice. See it on Field Notes."
    }
  ]

customizationGuides :: Array ThemeGuideEntry
customizationGuides =
  [ { label: "Accent-derived product theme"
    , path: sampleIndexPath northstarSample
    , summary: "Starts from the official system, then overrides accent, typography, spacing, and surface for a launch-oriented product voice."
    }
  , { label: "Accent-derived profile theme"
    , path: sampleIndexPath minaSample
    , summary: "Keeps the official system but tilts it toward a warmer, narrower profile surface."
    }
  ]

sampleSites :: Array SampleSite
sampleSites = sampleSitesWithPaths rootShowcasePaths

sampleSitesWithPaths :: ShowcasePaths -> Array SampleSite
sampleSitesWithPaths paths =
  [ { slug: docsSample.slug
    , label: docsSample.label
    , summary: docsSample.summary
    , theme: officialTheme
    , site: docsSampleSite paths
    , assets: []
    }
  , { slug: northstarSample.slug
    , label: northstarSample.label
    , summary: northstarSample.summary
    , theme: productTheme
    , site: productSite paths
    , assets:
        [ { path: "samples/northstar-cloud/assets/operations-map.svg"
          , content: northstarDiagramSvg
          }
        ]
    }
  , { slug: atelierSample.slug
    , label: atelierSample.label
    , summary: atelierSample.summary
    , theme: atelierTheme
    , site: atelierSite paths
    , assets: []
    }
  , { slug: minaSample.slug
    , label: minaSample.label
    , summary: minaSample.summary
    , theme: profileTheme
    , site: profileSite paths
    , assets:
        [ { path: "samples/mina-arai/assets/profile-portrait.svg"
          , content: minaPortraitSvg
          }
        ]
    }
  , { slug: summitSample.slug
    , label: summitSample.label
    , summary: summitSample.summary
    , theme: summitTheme
    , site: summitSite paths
    , assets: []
    }
  , { slug: journalSample.slug
    , label: journalSample.label
    , summary: journalSample.summary
    , theme: journalTheme
    , site: journalSite paths
    , assets: []
    }
  ]

showcaseSite :: Site
showcaseSite = showcaseSiteWithPaths rootShowcasePaths

showcaseSiteWithPaths :: ShowcasePaths -> Site
showcaseSiteWithPaths paths =
  withNavigation
    (showcaseNavigation paths)
    (withDescription
      "A pressure-test gallery for Portico across docs, landing, portfolio, profile, event, and publication surfaces."
      (site
        "Portico Sample Lab"
        [ withSummary
            "Multiple generated sites used to pressure-test Portico's semantic and themed output across six public site shapes."
            (page
              "index"
              Landing
              "Portico Sample Lab"
              [ namedSection
                  "Overview"
                  [ HeroBlock
                      (withActions
                        ([ slugLinkCard "Browse the preset catalog" "presets" (Just "Start from the theme chooser before jumping into individual samples.") ] <> map sampleCard (sampleSitesWithPaths paths))
                        (withEyebrow
                          "Pressure test"
                          (hero
                            "One library, multiple public surfaces."
                            "This sample lab exists to expose where Portico's site model still feels too weak across different categories.")))
                  , FeatureGridBlock
                      [ feature "Docs" "An official docs surface checks navigation, guides, and release adjacency."
                      , feature "Product" "A landing sample pressures promise, proof, and rollout communication."
                      , feature "Portfolio" "A case-study site pressures metrics, milestones, and public proof."
                      , feature "Profile" "A profile hybrid checks how biography, practice, and flagship work coexist."
                      , feature "Microsite" "An event sample checks schedule-heavy communication and narrow calls to action."
                      , feature "Publication" "An essay surface checks pacing, calm hierarchy, and archive-like movement."
                      ]
                  , CalloutBlock
                      (callout Quiet "How to navigate" "Every sample keeps an explicit Overview route in the header, a Sample Lab route back to this hub, and a Continue exploring section at the bottom of each page.")
                  ]
              , namedSection
                  "Samples"
                  [ LinkGridBlock (map sampleCard (sampleSitesWithPaths paths))
                  , CalloutBlock
                      (callout Accent "Why this exists" "Portico should be hardened by real sample surfaces, not only by one official-site happy path.")
                  ]
              ])
        , withSummary
            "A guide to choosing between the official presets and the current customization ladder."
            (page
              "presets"
              Documentation
              "Preset Catalog"
              [ withSectionId
                  "chooser"
                  (namedSection
                    "Chooser"
                    [ HeroBlock
                        (withActions
                          [ collectionLinkCard "See SignalPaper in practice" (sampleIndexPath docsSample) (Just "Open the Northline Docs sample.")
                          , collectionLinkCard "See NightCircuit in practice" (sampleIndexPath summitSample) (Just "Open the Signal Summit sample.")
                          , collectionLinkCard "See accent customization" (sampleIndexPath northstarSample) (Just "Open the Northstar Cloud sample.")
                          ]
                          (withEyebrow
                            "Theme guide"
                            (hero
                              "Pick a preset by intent, not by accent."
                              "This catalog maps each official preset and customization path to the generated sample surfaces, so theme choice starts from site category and reading feel.")))
                    , FeatureGridBlock
                        [ feature "Start from site shape" "Docs, events, portfolios, and essays want different reading tempos before they want different accent colors."
                        , feature "Read the chrome" "Frame width, pill shape, and surface treatment now differ between presets, so the preset choice changes structure as well as color."
                        , feature "Customize in layers" "Stay on the official theme system, then add accent, palette, typography, spacing, and surface overrides only when the preset itself stops being enough."
                        ]
                    ])
              , withSectionId
                  "official-presets"
                  (namedSection
                    "Official presets"
                    [ LinkGridBlock (map themeGuideCard officialPresetGuides)
                    , CalloutBlock
                        (callout Quiet "Selection rule" "Choose the preset whose reading posture matches the site: calm official, warm studio, bold technical, or quiet publication.")
                    ])
              , withSectionId
                  "customization"
                  (namedSection
                    "Customization ladder"
                    [ FeatureGridBlock
                        [ feature "Level 1: default" "Use officialTheme when the calm baseline already fits the site."
                        , feature "Level 2: preset" "Use officialThemeWithPreset when one of the built-in voices already matches the site category."
                        , feature "Level 3: accent or palette" "Use officialThemeWithAccent or officialThemeWithPalette when the voice is right but the color system should shift."
                        , feature "Level 4: structural polish" "Add withTypography, withSpacing, withSurface, withRadius, and withShadow only when the site needs a specific public posture."
                        ]
                    , CodeBlock
                        (codeSample
                          "import Portico\n\nlaunchTheme =\n  officialThemeWith\n    ((officialThemeOptions SignalPaper)\n      { accent = Just \"#0f766e\"\n      , typography = Just\n          { display: \"\\\"Sora\\\", \\\"Avenir Next\\\", sans-serif\"\n          , body: \"\\\"Manrope\\\", \\\"Helvetica Neue\\\", sans-serif\"\n          , mono: \"\\\"IBM Plex Mono\\\", monospace\"\n          }\n      , spacing = Just\n          { pageInset: \"3.2rem\"\n          , pageTop: \"4.7rem\"\n          , pageBottom: \"5.6rem\"\n          , sectionGap: \"3.2rem\"\n          , stackGap: \"1.3rem\"\n          , cardPadding: \"1.4rem\"\n          , heroPadding: \"2.35rem\"\n          }\n      , surface = Just\n          { frameWidth: \"74rem\"\n          , brandRadius: \"1.1rem\"\n          , pillRadius: \"0.95rem\"\n          , headerSurface: \"linear-gradient(180deg,color-mix(in srgb,var(--accent) 7%,white) 0%,var(--panel) 100%)\"\n          , heroSurface: \"linear-gradient(135deg,color-mix(in srgb,var(--accent) 15%,var(--panel)) 0%,var(--panel) 58%,color-mix(in srgb,var(--accent) 4%,white) 100%)\"\n          , quoteSurface: \"linear-gradient(180deg,color-mix(in srgb,var(--accent) 10%,var(--panel)) 0%,var(--panel) 100%)\"\n          }\n      , radius = Just \"26px\"\n      , shadow = Just \"0 32px 88px rgba(11, 47, 40, 0.16)\"\n      })"
                          (Just "purescript")
                          (Just "Layered customization starting from the official theme system"))
                    , LinkGridBlock (map themeGuideCard customizationGuides)
                    ])
              ])
        ]))

sampleNavItem :: SampleSite -> NavItem
sampleNavItem sampleSite =
  collectionNavItem sampleSite.label (sampleIndexPath sampleSite)

showcaseNavigation :: ShowcasePaths -> Array NavItem
showcaseNavigation paths =
  maybeOfficialSiteNavItem paths <> [ slugNavItem "Preset Catalog" "presets" ] <> map sampleNavItem (sampleSitesWithPaths paths)

sampleCard :: SampleSite -> LinkCard
sampleCard sampleSite =
  collectionLinkCard sampleSite.label (sampleIndexPath sampleSite) (Just sampleSite.summary)

themeGuideCard :: ThemeGuideEntry -> LinkCard
themeGuideCard guide =
  collectionLinkCard guide.label guide.path (Just guide.summary)

sampleIndexPath :: forall r. { slug :: String | r } -> String
sampleIndexPath sampleSite =
  "samples/" <> sampleSite.slug <> "/index.html"

sampleSiteNavigation :: ShowcasePaths -> Array NavItem -> Array NavItem
sampleSiteNavigation paths localNavigation =
  [ slugNavItem "Overview" "index"
  ] <> localNavigation <> maybeOfficialSiteNavItem paths <> [ collectionNavItem "Sample Lab" paths.labHomePath ]

decorateSampleSite :: ShowcasePaths -> String -> Array NavItem -> Site -> Site
decorateSampleSite paths currentSlug localNavigation currentSite =
  withNavigation
    (sampleSiteNavigation paths localNavigation)
    (currentSite { pages = map (appendWayfindingSection paths currentSlug) currentSite.pages })

appendWayfindingSection :: ShowcasePaths -> String -> Page -> Page
appendWayfindingSection paths currentSlug currentPage =
  currentPage { sections = currentPage.sections <> [ sampleWayfindingSection paths currentSlug currentPage ] }

sampleWayfindingSection :: ShowcasePaths -> String -> Page -> Section
sampleWayfindingSection paths currentSlug currentPage =
  namedSection
    "Continue exploring"
    [ CalloutBlock
        (callout Quiet "Wayfinding" "Use Overview to return to this sample's front door, or jump sideways into the rest of the lab from here.")
    , LinkGridBlock (wayfindingCards paths currentSlug currentPage)
    ]

wayfindingCards :: ShowcasePaths -> String -> Page -> Array LinkCard
wayfindingCards paths currentSlug currentPage =
  currentSampleOverviewCard currentPage <> [ sampleLabCard paths ] <> siblingSampleCards currentSlug

currentSampleOverviewCard :: Page -> Array LinkCard
currentSampleOverviewCard currentPage =
  if currentPage.slug == "index" then
    []
  else
    [ slugLinkCard "Back to this sample overview" "index" (Just "Return to the front door for the current sample.") ]

sampleLabCard :: ShowcasePaths -> LinkCard
sampleLabCard paths =
  collectionLinkCard
    "Open the sample lab"
    paths.labHomePath
    (Just "Return to the hub and compare the other site shapes from one place.")

sampleLabReturnCard :: ShowcasePaths -> String -> LinkCard
sampleLabReturnCard paths summary =
  collectionLinkCard "Return to the sample lab" paths.labHomePath (Just summary)

siblingSampleCards :: String -> Array LinkCard
siblingSampleCards currentSlug =
  map sampleDirectoryCard (filter (\sample -> sample.slug /= currentSlug) sampleDirectory)

sampleDirectoryCard :: SampleDirectoryEntry -> LinkCard
sampleDirectoryCard sample =
  collectionLinkCard sample.label (sampleIndexPath sample) (Just sample.summary)

maybeOfficialSiteNavItem :: ShowcasePaths -> Array NavItem
maybeOfficialSiteNavItem paths =
  case paths.officialHomePath of
    Just path -> [ collectionNavItem "Official Site" path ]
    Nothing -> []

mountedIndexPath :: String -> String
mountedIndexPath mountPath
  | mountPath == "" = "index.html"
  | otherwise = mountPath <> "/index.html"

showcaseTheme :: Theme
showcaseTheme =
  officialThemeWithPalette
    { background: "#f4efe7"
    , panel: "#fffaf3"
    , text: "#17130f"
    , mutedText: "#6f6257"
    , accent: "#9a3412"
    , border: "#decebd"
    }

atelierTheme :: Theme
atelierTheme = officialThemeWithPreset CopperLedger

summitTheme :: Theme
summitTheme = officialThemeWithPreset NightCircuit

journalTheme :: Theme
journalTheme = officialThemeWithPreset BlueLedger

productTheme :: Theme
productTheme =
  officialThemeWith
    ((officialThemeOptions SignalPaper)
      { accent = Just "#0f766e"
      , typography =
          Just
            { display: "\"Sora\", \"Avenir Next\", sans-serif"
            , body: "\"Manrope\", \"Helvetica Neue\", sans-serif"
            , mono: "\"IBM Plex Mono\", monospace"
            }
      , spacing =
          Just
            { pageInset: "3.2rem"
            , pageTop: "4.7rem"
            , pageBottom: "5.6rem"
            , sectionGap: "3.2rem"
            , stackGap: "1.3rem"
            , cardPadding: "1.4rem"
            , heroPadding: "2.35rem"
            }
      , surface =
          Just
            { frameWidth: "74rem"
            , brandRadius: "1.1rem"
            , pillRadius: "0.95rem"
            , headerSurface: "linear-gradient(180deg,color-mix(in srgb,var(--accent) 7%,white) 0%,var(--panel) 100%)"
            , heroSurface: "linear-gradient(135deg,color-mix(in srgb,var(--accent) 15%,var(--panel)) 0%,var(--panel) 58%,color-mix(in srgb,var(--accent) 4%,white) 100%)"
            , quoteSurface: "linear-gradient(180deg,color-mix(in srgb,var(--accent) 10%,var(--panel)) 0%,var(--panel) 100%)"
            }
      , radius = Just "26px"
      , shadow = Just "0 32px 88px rgba(11, 47, 40, 0.16)"
      })

profileTheme :: Theme
profileTheme =
  officialThemeWith
    ((officialThemeOptions SignalPaper)
      { accent = Just "#c2410c"
      , typography =
          Just
            { display: "\"Fraunces\", Georgia, serif"
            , body: "\"Public Sans\", \"Helvetica Neue\", sans-serif"
            , mono: "\"IBM Plex Mono\", monospace"
            }
      , spacing =
          Just
            { pageInset: "3rem"
            , pageTop: "4.15rem"
            , pageBottom: "5rem"
            , sectionGap: "3.05rem"
            , stackGap: "1.25rem"
            , cardPadding: "1.45rem"
            , heroPadding: "2.1rem"
            }
      , surface =
          Just
            { frameWidth: "66rem"
            , brandRadius: "1.4rem"
            , pillRadius: "999px"
            , headerSurface: "linear-gradient(180deg,color-mix(in srgb,var(--accent) 5%,white) 0%,var(--panel) 100%)"
            , heroSurface: "linear-gradient(180deg,color-mix(in srgb,var(--accent) 11%,white) 0%,var(--panel) 62%,var(--panel) 100%)"
            , quoteSurface: "linear-gradient(145deg,color-mix(in srgb,var(--accent) 9%,white) 0%,var(--panel) 100%)"
            }
      , radius = Just "24px"
      , shadow = Just "0 28px 78px rgba(45, 23, 10, 0.14)"
      })

docsSampleSite :: ShowcasePaths -> Site
docsSampleSite paths =
  decorateSampleSite
    paths
    docsSample.slug
    [ slugNavItem "Concepts" "concepts"
    , slugNavItem "Reference" "reference/routes"
    , slugNavItem "Release" "releases/2-1-0"
    ]
    (withDescription
      "A documentation surface for a data pipeline toolkit."
      (site
        "Northline Docs"
        [ withSummary
            "A calm docs front door with concepts, reference, and release adjacency."
            (page
              "index"
              Landing
              "Northline Docs"
              [ namedSection
                  "Overview"
                  [ HeroBlock
                      (withActions
                        [ slugLinkCard "Read the concepts guide" "concepts" (Just "Start with the high-level model before dropping into reference details.")
                        , slugLinkCard "Open the route reference" "reference/routes" (Just "Jump directly to the nested reference page and route-helper examples.")
                        , sampleLabReturnCard paths "Compare this docs surface against the rest of the pressure-test gallery."
                        ]
                        (withEyebrow
                          "Docs sample"
                          (hero
                            "Calm docs should orient before they impress."
                            "This sample pressures Portico with a docs front door, concept page, nested reference page, and release adjacency without turning the surface into a control console.")))
                  , FeatureGridBlock
                      [ feature "Concept pages" "A docs front door should tell readers what they are looking at before it starts drilling into procedures."
                      , feature "Nested reference" "The route model has to stay coherent even once reference pages stop living at the top level."
                      , feature "Release adjacency" "Docs sites often need release notes nearby without forcing a second, unrelated surface."
                      , feature "Calm wayfinding" "The page should keep next steps obvious without turning navigation into a dashboard."
                      ]
                  , CalloutBlock
                      (callout Accent "Pressure point" "This sample exists so the docs category can be pressure-tested without duplicating the official Portico site itself.")
                  ]
              ])
        , withSummary
            "A conceptual guide page for the docs sample."
            (page
              "concepts"
              Documentation
              "Data Flow"
              [ namedSection
                  "Model"
                  [ ProseBlock "Northline treats ingestion as one public pipeline: capture, normalize, then publish. The docs surface should let readers understand that shape before they need every switch and flag."
                  , TimelineBlock
                      [ timelineEntry "Capture" "Start with the source boundary and what enters the system." Nothing
                      , timelineEntry "Normalize" "Turn source variance into one stable public model before reference details take over." Nothing
                      , timelineEntry "Publish" "Make the output path explicit so guides, release notes, and support surfaces stay aligned." Nothing
                      ]
                  , CodeBlock
                      (codeSample
                        "pipeline:\n  capture: ingest source events\n  normalize: map fields to one public schema\n  publish: emit route-safe static output"
                        (Just "yaml")
                        (Just "Concept sketch"))
                  ]
              , namedSection
                  "Next"
                  [ LinkGridBlock
                      [ slugLinkCard "Open the route reference" "reference/routes" (Just "Move from concept framing into nested reference detail.")
                      , slugLinkCard "Read the release note" "releases/2-1-0" (Just "See how a docs release page can live next to guides and reference.")
                      , slugLinkCard "Back to the docs front door" "index" (Just "Return to the sample home page.")
                      ]
                  ]
              ])
        , withSummary
            "A nested reference page for docs-style crosslinking."
            (page
              "reference/routes"
              Documentation
              "Route Helpers"
              [ namedSection
                  "Reference"
                  [ FeatureGridBlock
                      [ feature "`slugPath`" "Use page slugs as semantic site routes instead of hand-writing output paths."
                      , feature "`collectionLinkCard`" "Link back into a mounted collection when a site sits inside a larger static output tree."
                      , feature "`emitMountedSite`" "Emit a whole site below a mount point without losing coherent relative links."
                      ]
                  , CodeBlock
                      (codeSample
                        "import Portico\n\nsampleSite =\n  withNavigation\n    [ collectionNavItem \"Sample Lab\" \"../index.html\" ]\n    (site \"Northline Docs\" ...)"
                        (Just "purescript")
                        (Just "Mounted docs route sketch"))
                  ]
              , namedSection
                  "Questions"
                  [ FaqBlock
                      [ faqEntry "When should I use collection helpers?" "Use them when the current site is being emitted under a mount path inside a larger static output tree."
                      , faqEntry "Should docs pages hand-write relative links?" "No. Prefer Portico route helpers so nested pages stay coherent as the output tree evolves."
                      , faqEntry "Does docs IA belong in the theme layer?" "No. Theme can shape reading posture, but docs structure still belongs in the semantic site model."
                      ]
                  , LinkGridBlock
                      [ slugLinkCard "Back to the docs front door" "index" (Just "Return to the sample overview.")
                      , slugLinkCard "Read the concepts guide" "concepts" (Just "Return to the conceptual explanation page.")
                      , slugLinkCard "Read the release note" "releases/2-1-0" (Just "See release adjacency from a nested reference page.")
                      ]
                  ]
              ])
        , withSummary
            "A release note page living next to guides and reference."
            (page
              "releases/2-1-0"
              ReleaseNotes
              "Release 2.1.0"
              [ namedSection
                  "Highlights"
                  [ FeatureGridBlock
                      [ feature "Guide and reference adjacency" "Release notes sit next to docs content instead of forcing a separate public surface."
                      , feature "Route-safe output" "The sample keeps nested reference and release routes coherent under one static tree."
                      , feature "Calm public posture" "The release page reads like docs truth, not like a second marketing site."
                      ]
                  , CalloutBlock
                      (callout Quiet "Pressure point" "This page checks whether Portico can keep release communication close to documentation without flattening the site into one tone.")
                  ]
              , namedSection
                  "Next"
                  [ LinkGridBlock
                      [ slugLinkCard "Back to the docs front door" "index" (Just "Return to the sample overview.")
                      , slugLinkCard "Open the route reference" "reference/routes" (Just "Jump back into the nested reference page.")
                      ]
                  ]
              ])
        ]))

atelierSite :: ShowcasePaths -> Site
atelierSite paths =
  decorateSampleSite
    paths
    atelierSample.slug
    [ slugNavItem "Flagship case study" "case-study"
    ]
    (withDescription
      "A portfolio surface for a small strategy and design studio."
      (site
        "Atelier North"
        [ withSummary
            "Case-study driven portfolio pages with metrics and staged credibility."
            (page
              "index"
              Showcase
              "Atelier North"
              [ namedSection
                  "Studio"
                  [ HeroBlock
                      (withActions
                        [ slugLinkCard "Read the flagship case study" "case-study" (Just "See how the system behaves when the proof is concrete.")
                        , sampleLabReturnCard paths "Compare this surface against the other pressure tests."
                        ]
                        (withEyebrow
                          "Portfolio sample"
                          (hero
                            "Case studies should feel calm, not like dashboards."
                            "This sample pressures Portico against portfolio proof, structured metrics, and a narrative project timeline.")))
                  , MetricsBlock
                      [ metric "12" "launches" (Just "Public site launches across three years.")
                      , metric "7" "weeks" (Just "From alignment to final rollout on the featured project.")
                      , metric "4" "markets" (Just "Product surfaces localized without redesigning the whole story.")
                      ]
                  ]
              , namedSection
                  "Offer"
                  [ FeatureGridBlock
                      [ feature "Narrative proof" "Portfolio surfaces should pace evidence instead of dumping outputs."
                      , feature "Public metrics" "A few well-placed numbers can carry credibility without turning into analytics UI."
                      , feature "Tight routes" "A studio site still wants a short path from intro to concrete case study."
                      ]
                  ]
              ])
        , withSummary
            "A flagship redesign framed as a case study."
            (page
              "case-study"
              Showcase
              "Lattice Robotics Rebrand"
              [ namedSection
                  "Snapshot"
                  [ MetricsBlock
                      [ metric "38%" "faster orientation" (Just "First-time visitors reached product pages faster in user walkthroughs.")
                      , metric "3" "audiences aligned" (Just "Buyers, implementers, and partners read from one clear front door.")
                      ]
                  , CalloutBlock
                      (callout Strong "Pressure point" "This sample exposes whether Portico can carry proof and pacing without collapsing into generic marketing markup.")
                  ]
              , namedSection
                  "Timeline"
                  [ TimelineBlock
                      [ timelineEntry "Week 1: Audit the public surface" "We mapped repeated promises, buried entry points, and the moments where the old site stopped orienting new visitors." (Just "Research")
                      , timelineEntry "Week 3: Rebuild the information spine" "The new structure pulled product explanation, implementation proof, and partner trust into one readable sequence." (Just "Architecture")
                      , timelineEntry "Week 7: Ship the polished release" "Launch copy, case-study proof, and support routes were all tuned together instead of being sequenced as separate afterthoughts." (Just "Release")
                      ]
                  , LinkGridBlock
                      [ slugLinkCard "Return to the studio home" "index" (Just "Back to the portfolio front door.")
                      ]
                  ]
              ])
        ]))

productSite :: ShowcasePaths -> Site
productSite paths =
  decorateSampleSite
    paths
    northstarSample.slug
    [ slugNavItem "Proof" "proof"
    , slugNavItem "Rollout" "rollout"
    ]
    (withDescription
      "A product landing surface for a publishing operations platform."
      (site
        "Northstar Cloud"
        [ withSummary
            "A landing page balancing product promise, operational proof, and a rollout route."
            (page
              "index"
              Landing
              "Northstar Cloud"
              [ namedSection
                  "Launch"
                  [ HeroBlock
                      (withActions
                        [ slugLinkCard "Review customer proof" "proof" (Just "See whether Portico can carry proof without turning into an app dashboard.")
                        , slugLinkCard "See the rollout path" "rollout" (Just "Pressure-test sequence-heavy implementation communication.")
                        , sampleLabReturnCard paths "Compare this landing surface against the other samples."
                        ]
                        (withEyebrow
                          "Product landing sample"
                          (hero
                            "A landing page should promise a better operating shape."
                            "This sample pressures Portico with product language, customer proof, and rollout framing without leaning on app-shell patterns.")))
                  , MetricsBlock
                      [ metric "9 days" "to first publish" (Just "Teams move from setup to a stable release path without rebuilding their process.")
                      , metric "3" "teams aligned" (Just "Product, editorial, and support share one public launch spine.")
                      , metric "86%" "handoff reduction" (Just "Launch checklists collapse into one clearly owned sequence.")
                      ]
                  ]
              , namedSection
                  "Why teams switch"
                  [ FeatureGridBlock
                      [ feature "One publishing spine" "The site should explain the system in terms of operating shape, not feature sprawl."
                      , feature "Credible proof" "Landing pages need one or two pieces of hard evidence placed where belief actually changes."
                      , feature "Short next steps" "The path from promise to rollout should feel obvious even on static output."
                      ]
                  , QuoteBlock
                      (quote
                        "Northstar replaced three disconnected launch checklists with one publishing spine."
                        "Elena Park, platform lead at Juniper Health"
                        (Just "Customer note"))
                  , ImageBlock
                      (withCaption
                        "Self-authored SVG artwork used to pressure-test mounted site assets and image rendering."
                        (siteImage
                          "Abstract diagram showing a publishing operations flow from editorial source to public launch."
                          "assets/operations-map.svg"))
                  ]
              , namedSection
                  "Common questions"
                  [ FaqBlock
                      [ faqEntry "Can we keep our existing docs URLs?" "Yes. Northstar is meant to tighten the publishing path without forcing a public information reset."
                      , faqEntry "Who owns the rollout path?" "The rollout route is shared, but one visible owner keeps launch decisions from bouncing between teams."
                      , faqEntry "Does this replace our CMS?" "Not necessarily. The point is to stabilize the operating model first and integrate with the tools already doing useful work."
                      ]
                  ]
              ])
        , withSummary
            "A proof page that mixes customer voice, metrics, and clear evidence."
            (page
              "proof"
              Showcase
              "Customer Proof"
              [ namedSection
                  "Signal"
                  [ QuoteBlock
                      (quote
                        "The new flow made release week feel procedural instead of theatrical."
                        "Mara Singh, launch manager at Transit Layer"
                        (Just "Implementation note"))
                  , MetricsBlock
                      [ metric "42%" "fewer release questions" (Just "Support load dropped once the public path stopped contradicting the internal process.")
                      , metric "2" "handoffs removed" (Just "Content review and launch verification now live in one visible sequence.")
                      ]
                  , CalloutBlock
                      (callout Accent "Pressure point" "This page checks whether Portico can hold customer proof without collapsing into a feature comparison table.")
                  ]
              , namedSection
                  "Traction"
                  [ FeatureGridBlock
                      [ feature "Operational language" "The page speaks in changed workflow rather than isolated features."
                      , feature "Customer witness" "One direct quote can carry more belief than six generalized slogans."
                      , feature "Focused exits" "The sample keeps the next move narrow instead of offering every possible route."
                      ]
                  , LinkGridBlock
                      [ slugLinkCard "Back to the landing page" "index" (Just "Return to the product front door.")
                      , slugLinkCard "View the rollout path" "rollout" (Just "See the implementation sequence that follows the promise.")
                      ]
                  ]
              ])
        , withSummary
            "A rollout page used to test sequence-heavy onboarding communication."
            (page
              "rollout"
              Documentation
              "Rollout Path"
              [ namedSection
                  "Sequence"
                  [ TimelineBlock
                      [ timelineEntry "Day 1: Map the public promise" "We align the launch message, docs entry point, and success conditions before anyone starts rewriting blocks in isolation." (Just "Alignment")
                      , timelineEntry "Day 3: Rebuild the release path" "The system compresses approvals, asset readiness, and public publishing into one visible path." (Just "Setup")
                      , timelineEntry "Day 9: Ship the first stable release" "The team leaves with a repeatable publishing rhythm instead of a one-off rescue motion." (Just "Launch")
                      ]
                  , CodeBlock
                      (codeSample
                        "launch_owner: editorial-platform\npublic_front_door: /launch\nrelease_checklist:\n  - verify assets\n  - confirm docs route\n  - publish home update"
                        (Just "yaml")
                        (Just "Rollout handoff sketch"))
                  , ProseBlock "A landing surface often needs one implementation page nearby. This sample checks whether Portico can hold that deeper sequence without losing the clarity of the front door."
                  ]
              , namedSection
                  "Next move"
                  [ LinkGridBlock
                      [ slugLinkCard "Return to the landing page" "index" (Just "Back to the product promise.")
                      , slugLinkCard "Review customer proof" "proof" (Just "Cross-check the rollout path against customer outcomes.")
                      ]
                  ]
              ])
        ]))

profileSite :: ShowcasePaths -> Site
profileSite paths =
  decorateSampleSite
    paths
    minaSample.slug
    [ slugNavItem "Flagship case study" "work/harbor-clinic"
    ]
    (withDescription
      "A profile and case-study hybrid for an independent design engineer."
      (site
        "Mina Arai"
        [ withSummary
            "A profile front door that leads directly into one flagship case study."
            (page
              "index"
              Profile
              "Mina Arai"
              [ namedSection
                  "Profile"
                  [ HeroBlock
                      (withActions
                        [ slugLinkCard "Read the Harbor Clinic case study" "work/harbor-clinic" (Just "See whether the DSL can carry biography and proof without splitting into different systems.")
                        , sampleLabReturnCard paths "Compare this hybrid against the other surfaces."
                        ]
                        (withEyebrow
                          "Profile hybrid sample"
                          (hero
                            "An independent profile should feel like a point of view, not a resume dump."
                            "This sample pressures Portico with bio framing, selected proof, and a direct path into one flagship case study.")))
                  , QuoteBlock
                      (quote
                        "Mina brings editorial judgment into implementation instead of treating copy and code as separate handoffs."
                        "Ryo Matsuda, product lead at Harbor Clinic"
                        (Just "Collaborator note"))
                  ]
              , namedSection
                  "Practice"
                  [ FeatureGridBlock
                      [ feature "Editorial systems" "The profile should communicate how the work is done, not only where it shipped."
                      , feature "Implementation pairing" "The case study route needs to feel adjacent to the profile, not bolted on."
                      , feature "Selective proof" "A few chosen metrics should do more than a long archive of generic project cards."
                      ]
                  , MetricsBlock
                      [ metric "9" "years" (Just "Working across content systems, design, and front-end implementation.")
                      , metric "14" "launches" (Just "Public surfaces shipped with close writing and implementation collaboration.")
                      , metric "3" "roles bridged" (Just "Strategy, interface design, and production-level frontend work.")
                      ]
                  ]
              , namedSection
                  "Selected collaborators"
                  [ PeopleBlock
                      [ person "Ryo Matsuda" "Product lead" "Turns service constraints into a clear decision spine for public-facing products." (Just "Harbor Clinic")
                      , person "Leah Stone" "Editorial strategist" "Helps teams keep message architecture coherent from homepage copy through support docs." (Just "Independent collaborator")
                      , person "Kenji Watanabe" "Frontend partner" "Pairs closely on production implementation so the written model survives launch pressure." (Just "Launch engineering")
                      ]
                  , ImageBlock
                      (withCaption
                        "Self-authored SVG portrait artwork for testing image treatment on profile surfaces."
                        (siteImage
                          "Abstract portrait illustration with warm tones and profile label."
                          "assets/profile-portrait.svg"))
                  ]
              ])
        , withSummary
            "A flagship service redesign nested under the work route."
            (page
              "work/harbor-clinic"
              Showcase
              "Harbor Clinic Service Redesign"
              [ namedSection
                  "Outcome"
                  [ MetricsBlock
                      [ metric "31%" "faster appointment choice" (Just "Visitors reached the correct service page sooner during moderated walkthroughs.")
                      , metric "2" "audiences unified" (Just "Patients and referring partners now enter through one coherent surface.")
                      ]
                  , CalloutBlock
                      (callout Strong "Pressure point" "This case study checks whether Portico can keep a personal voice while still presenting concrete project proof.")
                  ]
              , namedSection
                  "Approach"
                  [ TimelineBlock
                      [ timelineEntry "Week 1: Listen to the front desk" "The redesign started with the repeated confusion points that staff were already carrying manually." (Just "Research")
                      , timelineEntry "Week 3: Rewrite the service map" "Navigation and copy were rebuilt together so the public surface stopped asking users to infer internal terminology." (Just "Structure")
                      , timelineEntry "Week 6: Pair on implementation" "The launch path stayed close to the written model instead of drifting during handoff." (Just "Delivery")
                      ]
                  , ProseBlock "A profile hybrid is useful because it tests whether a person, a practice, and a concrete project can all live inside one coherent site model without turning into separate content silos."
                  , LinkGridBlock
                      [ slugLinkCard "Back to the profile front door" "index" (Just "Return to the biography and practice overview.")
                      , sampleLabReturnCard paths "Jump back to the sample collection root from a nested case-study page."
                      ]
                  ]
              ])
        ]))

summitSite :: ShowcasePaths -> Site
summitSite paths =
  decorateSampleSite
    paths
    summitSample.slug
    [ slugNavItem "Schedule" "schedule"
    ]
    (withDescription
      "An event microsite for a one-day systems design summit."
      (site
        "Signal Summit"
        [ withSummary
            "An event microsite with concise metrics, urgency, and a schedule route."
            (page
              "index"
              Microsite
              "Signal Summit"
              [ namedSection
                  "Launch"
                  [ HeroBlock
                      (withActions
                        [ slugLinkCard "View the schedule" "schedule" (Just "See whether the timeline block can carry an agenda.")
                        , sampleLabReturnCard paths "Compare this microsite against the other samples."
                        ]
                        (withEyebrow
                          "Event sample"
                          (hero
                            "A one-day summit should read fast."
                            "This sample pressures Portico with event-style urgency, registration cues, and schedule-heavy information.")))
                  , MetricsBlock
                      [ metric "1 day" "format" (Just "Single-track morning, breakout afternoon, closing panel.")
                      , metric "18" "sessions" (Just "Talks, demos, and roundtables across the day.")
                      , metric "420" "seats" (Just "Enough scarcity to matter, not enough to become theater.")
                      ]
                  ]
              , namedSection
                  "Signals"
                  [ FeatureGridBlock
                      [ feature "Fast orientation" "Microsites should make date, promise, and next action obvious at a glance."
                      , feature "Schedule depth" "The page has to compress a full day without reading like a spreadsheet."
                      , feature "Narrow intent" "Unlike docs, the microsite can stay ruthlessly focused on one moment."
                      ]
                  ]
              , namedSection
                  "Featured speakers"
                  [ PeopleBlock
                      [ person "Nadia Vale" "Systems editor" "Works on making public technical writing feel authored instead of auto-generated from internal tooling." (Just "Atlas Press")
                      , person "Omar Lin" "Design systems lead" "Pushes component libraries toward clearer tradeoffs instead of ever-larger option surfaces." (Just "Morrow Studio")
                      , person "Sofia Chen" "Platform PM" "Brings launch process, docs, and implementation concerns into one readable product story." (Just "Juniper Health")
                      ]
                  ]
              ])
        , withSummary
            "A schedule page used to test dense sequential communication."
            (page
              "schedule"
              Microsite
              "Schedule"
              [ namedSection
                  "Agenda"
                  [ TimelineBlock
                      [ timelineEntry "Opening keynote" "A fast orientation to the state of tool-grade interface work and where the public web still underserves it." (Just "09:00")
                      , timelineEntry "Pattern workshop" "A practical session on making design systems compress decisions instead of multiplying them." (Just "10:30")
                      , timelineEntry "Public surfaces clinic" "Three teams walk through live rewrites of docs, landing, and release-note flows." (Just "13:00")
                      , timelineEntry "Closing panel" "What static-first systems should keep opinionated, and what they should leave open." (Just "17:30")
                      ]
                  , LinkGridBlock
                      [ slugLinkCard "Back to summit home" "index" (Just "Return to the registration-facing front door.")
                      ]
                  ]
              , namedSection
                  "Logistics FAQ"
                  [ FaqBlock
                      [ faqEntry "Will session recordings be published?" "Yes. Attendees receive the recording set the following week, and selected sessions are released publicly later."
                      , faqEntry "Can one ticket cover a small team?" "No. The workshops are capped tightly, so each attendee needs their own seat."
                      , faqEntry "Is the venue suitable for quiet breakout work?" "Yes. The breakout floor is designed for focused group sessions rather than expo-style traffic."
                      ]
                  ]
              ])
        ]))

journalSite :: ShowcasePaths -> Site
journalSite paths =
  decorateSampleSite
    paths
    journalSample.slug
    [ slugNavItem "Current issue" "essay/making-quiet-tools"
    ]
    (withDescription
      "A quiet publication surface for notes, essays, and archives."
      (site
        "Field Notes"
        [ withSummary
            "A publication sample that leans on prose pacing and issue navigation."
            (page
              "index"
              Article
              "Field Notes"
              [ namedSection
                  "Current issue"
                  [ HeroBlock
                      (withActions
                        [ slugLinkCard "Read issue 07" "essay/making-quiet-tools" (Just "The current essay in the archive.")
                        , sampleLabReturnCard paths "Compare this publication surface against the other samples."
                        ]
                        (withEyebrow
                          "Publication sample"
                          (hero
                            "A publication surface should slow the reader down."
                            "This sample pressures Portico with calmer pacing, issue framing, and archive-like movement rather than conversion-heavy layout.")))
                  , MetricsBlock
                      [ metric "7" "issues" (Just "A small but growing archive.")
                      , metric "14 min" "reading time" (Just "Enough length to expose weak prose defaults.")
                      ]
                  ]
              , namedSection
                  "Archive cues"
                  [ FeatureGridBlock
                      [ feature "Slow hierarchy" "The page should invite reading, not only skimming."
                      , feature "Issue framing" "Publication surfaces need a sense of sequence even when the archive is small."
                      , feature "Quiet navigation" "Links should remain clear without turning the page into a menu."
                      ]
                  ]
              ])
        , withSummary
            "Issue 07 of the notebook archive."
            (page
              "essay/making-quiet-tools"
              Article
              "Making Quiet Tools"
              [ namedSection
                  "Essay"
                  [ ProseBlock "Quiet tools do not compete for attention with the work they exist to support. They compress friction, hold their shape under repetition, and stop speaking when they are no longer needed."
                  , ProseBlock "A publication surface has a similar responsibility. It should carry the argument forward, reveal the sequence of thought, and avoid the feeling that every paragraph was dropped into a generic container."
                  , CalloutBlock
                      (callout Quiet "Editorial note" "This sample exists to test whether Portico can stay calm on pages where the main action is reading.")
                  ]
              , namedSection
                  "Notebook trail"
                  [ TimelineBlock
                      [ timelineEntry "Notebook A" "Early drafts were too eager to explain the system instead of letting the examples do the work." (Just "Draft 1")
                      , timelineEntry "Notebook B" "The structure improved once the essay stopped pretending to be a product pitch and returned to observation." (Just "Draft 3")
                      , timelineEntry "Notebook C" "Final revisions cut most of the connective filler and let the argument move by pressure, not by slogans." (Just "Final")
                      ]
                  , LinkGridBlock
                      [ slugLinkCard "Back to the archive front" "index" (Just "Return to the issue overview.")
                      ]
                  ]
              ])
        ]))

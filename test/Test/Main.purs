module Test.Main where

import Prelude

import Data.Array as Array
import Data.Foldable (length)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), contains)
import Effect (Effect)
import Effect.Exception (throw)
import Example.Official.PublicSite (buildPublicSite, buildPublicSiteWithConfig)
import Example.Official.Site (officialSite)
import Example.Official.Showcase (buildShowcase, sampleSites, showcaseSite)
import Portico (AssetTarget(..), Block(..), OfficialPreset(..), PageKind(..), RenderedPage, Site, ValidationCode(..), ValidationDiagnostic, ValidationSeverity(..), defaultStylesheetPath, emitSite, hero, namedSection, officialTheme, officialThemeOptions, officialThemeWith, officialThemeWithAccent, officialThemeWithPalette, officialThemeWithPreset, page, renderSite, renderStaticSite, renderStylesheet, site, siteDiagnostics, siteNavItem, slugLinkCard, validateSite, withBaseUrl, withDefaultSocialImage, withDescription, withNavigation, withSectionId, withSocialImage, withSummary)
import Partial.Unsafe (unsafeCrashWith)
import Test.Support.FileSystem (pathExists, readTextFile, removeTree)

main :: Effect Unit
main = do
  let
    renderedPages = renderSite officialTheme officialSite
    renderedStaticSite = renderStaticSite defaultStylesheetPath officialTheme officialSite
    metadataRenderedPages = renderSite officialTheme metadataSite
    accentThemeStyles = renderStylesheet (officialThemeWithAccent "#c2410c")
    presetThemeStyles = renderStylesheet (officialThemeWithPreset NightCircuit)
    configuredThemeStyles =
      renderStylesheet
        (officialThemeWith
          ((officialThemeOptions NightCircuit)
            { accent = Just "#22c55e"
            , surface =
                Just
                  { frameWidth: "70rem"
                  , brandRadius: "1rem"
                  , pillRadius: "0.8rem"
                  , headerSurface: "linear-gradient(180deg,color-mix(in srgb,var(--accent) 5%,black) 0%,var(--panel) 100%)"
                  , heroSurface: "linear-gradient(135deg,color-mix(in srgb,var(--accent) 16%,var(--panel)) 0%,var(--panel) 100%)"
                  , quoteSurface: "linear-gradient(180deg,color-mix(in srgb,var(--accent) 12%,var(--panel)) 0%,var(--panel) 100%)"
                  }
            }))
    paletteThemeStyles =
      renderStylesheet
        (officialThemeWithPalette
          { background: "#fff8ef"
          , panel: "#fffcf7"
          , text: "#1a1814"
          , mutedText: "#74685a"
          , accent: "#c05621"
          , border: "#ead9c8"
          })
    officialDiagnostics = siteDiagnostics officialSite
    showcaseDiagnostics = siteDiagnostics showcaseSite
    invalidDiagnostics = (validateSite invalidSite).diagnostics
    outputDirectory = "/tmp/portico-test-output"
    showcaseOutputDirectory = "/tmp/portico-showcase-output"
    publicOutputDirectory = "/tmp/portico-public-output"
    pagesOutputDirectory = "/tmp/portico-pages-output"
  assert "expected eight rendered pages" (length renderedPages == 8)
  let
    homePage = expectRenderedPage "index.html" renderedPages
    learnPage = expectRenderedPage "learn/fit.html" renderedPages
    guidePage = expectRenderedPage "guide/getting-started.html" renderedPages
    aiPage = expectRenderedPage "guide/ai-path.html" renderedPages
    referencePage = expectRenderedPage "reference/public-surface.html" renderedPages
    themePage = expectRenderedPage "guide/theme-system.html" renderedPages
    publishabilityPage = expectRenderedPage "guide/publishability.html" renderedPages
    releasePage = expectRenderedPage "releases/0-1-0.html" renderedPages
  assert "document should include the site title" (contains (Pattern "Portico") homePage.html)
  assert "hero eyebrow should render" (contains (Pattern "Published static sites") homePage.html)
  assert "home page should advertise the sample lab" (contains (Pattern "href=\"lab/index.html\"") homePage.html)
  assert "home page should advertise the preset catalog" (contains (Pattern "href=\"lab/presets.html\"") homePage.html)
  assert "home page should render the new fit copy" (contains (Pattern "It is not a lighter Asterism") homePage.html)
  assert "home page should surface repo-first posture" (contains (Pattern "Pre-beta, repo-first") homePage.html)
  assert "learn page should explain the category boundary" (contains (Pattern "published public surfaces") learnPage.html)
  assert "learn page should call out the Asterism boundary" (contains (Pattern "Not a lighter Asterism") learnPage.html)
  assert "guide page should render code sample content" (contains (Pattern "import Portico") guidePage.html)
  assert "guide page should resolve the home route relatively" (contains (Pattern "href=\"../index.html\"") guidePage.html)
  assert "guide page should resolve theme links relatively" (contains (Pattern "href=\"theme-system.html\"") guidePage.html)
  assert "ai path should surface the repo-first skill" (contains (Pattern "portico-user skill") aiPage.html)
  assert "reference page should mention Portico.Validate" (contains (Pattern "Portico.Validate") referencePage.html)
  assert "theme guide should include officialThemeWith content" (contains (Pattern "officialThemeWith") themePage.html)
  assert "theme guide should link to the preset catalog relatively" (contains (Pattern "href=\"../lab/presets.html\"") themePage.html)
  assert "publishability page should mention validateSite" (contains (Pattern "validateSite") publishabilityPage.html)
  assert "publishability page should mention canonical and social metadata" (contains (Pattern "Canonical, OG, and Twitter tags are derived") publishabilityPage.html)
  assert "publishability page should mention the release-oriented verify command" (contains (Pattern "npm run verify") publishabilityPage.html)
  assert "release copy should render" (contains (Pattern "Portico is in public pre-beta") releasePage.html)
  assert "theme styles should render" (contains (Pattern "--accent:#0f766e") homePage.html)
  assert "inline render should include a style tag" (contains (Pattern "<style>") homePage.html)

  assert "static render should expose one shared asset" (length renderedStaticSite.assets == 1)
  case metadataRenderedPages of
    [ metadataHome, metadataGuide ] -> do
      assert "metadata home should emit a canonical url from the base url" (contains (Pattern "rel=\"canonical\" href=\"https://example.com/portico/index.html\"") metadataHome.html)
      assert "metadata home should fall back to the site social image" (contains (Pattern "property=\"og:image\" content=\"https://cdn.example.com/portico-card.png\"") metadataHome.html)
      assert "metadata home should emit a twitter image tag" (contains (Pattern "name=\"twitter:image\" content=\"https://cdn.example.com/portico-card.png\"") metadataHome.html)
      assert "metadata guide should emit a canonical url for nested pages" (contains (Pattern "rel=\"canonical\" href=\"https://example.com/portico/guide/metadata.html\"") metadataGuide.html)
      assert "metadata guide should emit the page url for open graph" (contains (Pattern "property=\"og:url\" content=\"https://example.com/portico/guide/metadata.html\"") metadataGuide.html)
      assert "metadata guide should resolve a site asset social image against the base url" (contains (Pattern "property=\"og:image\" content=\"https://example.com/portico/assets/guide-card.svg\"") metadataGuide.html)
      assert "metadata guide should emit the twitter image tag from the page override" (contains (Pattern "name=\"twitter:image\" content=\"https://example.com/portico/assets/guide-card.svg\"") metadataGuide.html)
      assert "metadata guide should emit article open graph type for documentation pages" (contains (Pattern "property=\"og:type\" content=\"article\"") metadataGuide.html)
      assert "metadata guide should emit a large twitter card when an image is present" (contains (Pattern "name=\"twitter:card\" content=\"summary_large_image\"") metadataGuide.html)
      assert "metadata guide should reuse the page summary for open graph description" (contains (Pattern "property=\"og:description\" content=\"A focused page for metadata coverage.\"") metadataGuide.html)
    _ ->
      throw "metadata render returned an unexpected page list"

  let
    staticHomePage = expectRenderedPage "index.html" renderedStaticSite.pages
    staticGuidePage = expectRenderedPage "guide/getting-started.html" renderedStaticSite.pages
    staticAiPage = expectRenderedPage "guide/ai-path.html" renderedStaticSite.pages
    staticThemePage = expectRenderedPage "guide/theme-system.html" renderedStaticSite.pages
    staticReleasePage = expectRenderedPage "releases/0-1-0.html" renderedStaticSite.pages
  assert "home page should link the shared stylesheet" (contains (Pattern "href=\"assets/portico.css\"") staticHomePage.html)
  assert "guide page should link the shared stylesheet relatively" (contains (Pattern "href=\"../assets/portico.css\"") staticGuidePage.html)
  assert "ai page should link the shared stylesheet relatively" (contains (Pattern "href=\"../assets/portico.css\"") staticAiPage.html)
  assert "theme page should link the shared stylesheet relatively" (contains (Pattern "href=\"../assets/portico.css\"") staticThemePage.html)
  assert "release page should link the shared stylesheet relatively" (contains (Pattern "href=\"../assets/portico.css\"") staticReleasePage.html)
  assert "static render should not inline styles" (not (contains (Pattern "<style>") staticHomePage.html))
  assert "static render should keep internal links relative on nested guide pages" (contains (Pattern "href=\"../index.html\"") staticGuidePage.html)
  assert "static render should avoid root-absolute internal links" (not (contains (Pattern "href=\"/guide/getting-started.html\"") staticHomePage.html))

  case renderedStaticSite.assets of
    [ stylesheet ] -> do
      assert "stylesheet asset should use the default path" (stylesheet.path == defaultStylesheetPath)
      assert "stylesheet asset should contain the hero styles" (contains (Pattern ".hero-block") stylesheet.content)
      assert "stylesheet asset should contain code block styles" (contains (Pattern ".code-block") stylesheet.content)
      assert "stylesheet asset should expose spacing variables" (contains (Pattern "--page-inset:3rem") stylesheet.content)
      assert "stylesheet asset should expose surface variables" (contains (Pattern "--frame-width:72rem") stylesheet.content)
    _ ->
      throw "renderStaticSite returned an unexpected asset list"

  assert "accent override should set the accent variable" (contains (Pattern "--accent:#c2410c") accentThemeStyles)
  assert "accent override should derive the border variable" (contains (Pattern "--border:color-mix(in srgb,#c2410c 18%,#d7cfc3)") accentThemeStyles)
  assert "preset theme should switch the background variable" (contains (Pattern "--background:#08111f") presetThemeStyles)
  assert "preset theme should switch the display font" (contains (Pattern "--display-font:\"Space Grotesk\", \"Avenir Next\", sans-serif") presetThemeStyles)
  assert "preset theme should switch the hero spacing variable" (contains (Pattern "--hero-padding:2.25rem") presetThemeStyles)
  assert "preset theme should switch the frame width" (contains (Pattern "--frame-width:76rem") presetThemeStyles)
  assert "preset theme should switch the pill radius" (contains (Pattern "--pill-radius:1rem") presetThemeStyles)
  assert "configured official theme should derive the preset background from accent" (contains (Pattern "--background:color-mix(in srgb,#22c55e 5%,#08111f)") configuredThemeStyles)
  assert "configured official theme should allow surface overrides" (contains (Pattern "--frame-width:70rem") configuredThemeStyles)
  assert "palette override should set the background variable" (contains (Pattern "--background:#fff8ef") paletteThemeStyles)
  assert "palette override should set the accent variable" (contains (Pattern "--accent:#c05621") paletteThemeStyles)
  assert "official docs site should validate cleanly" (Array.null officialDiagnostics)
  assert "showcase root should validate cleanly" (Array.null showcaseDiagnostics)
  assert "all pressure samples should validate cleanly" (Array.all (\sampleSite -> Array.null (siteDiagnostics sampleSite.site)) sampleSites)
  assert "invalid site should report missing index page" (hasDiagnostic ValidationError MissingIndexPage invalidDiagnostics)
  assert "invalid site should report duplicate page paths" (hasDiagnostic ValidationError DuplicatePagePath invalidDiagnostics)
  assert "invalid site should report empty navigation labels" (hasDiagnostic ValidationError EmptyNavigationLabel invalidDiagnostics)
  assert "invalid site should report broken navigation" (hasDiagnostic ValidationError BrokenSiteNavigation invalidDiagnostics)
  assert "invalid site should report empty link labels" (hasDiagnostic ValidationError EmptyLinkLabel invalidDiagnostics)
  assert "invalid site should report broken internal links" (hasDiagnostic ValidationError BrokenInternalLink invalidDiagnostics)
  assert "invalid site should report duplicate section ids" (hasDiagnostic ValidationError DuplicateSectionId invalidDiagnostics)
  assert "invalid site should warn on missing site description" (hasDiagnostic ValidationWarning MissingSiteDescription invalidDiagnostics)
  assert "invalid site should warn on missing page summaries" (hasDiagnostic ValidationWarning MissingPageSummary invalidDiagnostics)
  assert "invalid site should warn on non-leading hero placement" (hasDiagnostic ValidationWarning NonLeadingHero invalidDiagnostics)
  assert "invalid site should warn on empty page sections" (hasDiagnostic ValidationWarning EmptyPageSections invalidDiagnostics)

  removeTree outputDirectory
  emitSite outputDirectory officialTheme officialSite
  emittedHome <- readTextFile (outputDirectory <> "/index.html")
  emittedLearn <- readTextFile (outputDirectory <> "/learn/fit.html")
  emittedGuide <- readTextFile (outputDirectory <> "/guide/getting-started.html")
  emittedAi <- readTextFile (outputDirectory <> "/guide/ai-path.html")
  emittedReference <- readTextFile (outputDirectory <> "/reference/public-surface.html")
  emittedThemeGuide <- readTextFile (outputDirectory <> "/guide/theme-system.html")
  emittedPublishability <- readTextFile (outputDirectory <> "/guide/publishability.html")
  emittedRelease <- readTextFile (outputDirectory <> "/releases/0-1-0.html")
  emittedStylesheet <- readTextFile (outputDirectory <> "/assets/portico.css")
  assert "emitted home page should contain the hero title" (contains (Pattern "Build published static sites in PureScript.") emittedHome)
  assert "emitted home page should link the sample lab" (contains (Pattern "href=\"lab/index.html\"") emittedHome)
  assert "emitted learn page should contain the Asterism boundary" (contains (Pattern "Not a lighter Asterism") emittedLearn)
  assert "emitted guide page should contain guide prose" (contains (Pattern "supported path") emittedGuide)
  assert "emitted guide page should contain the code sample title" (contains (Pattern "One import, one site, one validated build path") emittedGuide)
  assert "emitted ai path should mention the implementation agent packet" (contains (Pattern "Minimal task packet for an implementation agent") emittedAi)
  assert "emitted reference page should mention Portico.Build" (contains (Pattern "Portico.Build") emittedReference)
  assert "emitted theme guide should link to the preset catalog relatively" (contains (Pattern "href=\"../lab/presets.html\"") emittedThemeGuide)
  assert "emitted publishability page should contain faq content" (contains (Pattern "Do I need a base URL to render?") emittedPublishability)
  assert "emitted release page should contain status callout" (contains (Pattern "Portico is in public pre-beta") emittedRelease)
  assert "emitted home page should link the shared stylesheet" (contains (Pattern "href=\"assets/portico.css\"") emittedHome)
  assert "emitted guide page should link the shared stylesheet" (contains (Pattern "href=\"../assets/portico.css\"") emittedGuide)
  assert "emitted stylesheet should contain shared block styles" (contains (Pattern ".block-card") emittedStylesheet)
  assert "emitted guide page should link home relatively" (contains (Pattern "href=\"../index.html\"") emittedGuide)

  assert "expected six pressure samples" (length sampleSites == 6)
  removeTree showcaseOutputDirectory
  buildShowcase showcaseOutputDirectory
  showcaseHome <- readTextFile (showcaseOutputDirectory <> "/index.html")
  showcasePresets <- readTextFile (showcaseOutputDirectory <> "/presets.html")
  showcaseStylesheet <- readTextFile (showcaseOutputDirectory <> "/assets/portico.css")
  docsSampleHome <- readTextFile (showcaseOutputDirectory <> "/samples/northline-docs/index.html")
  productSampleHome <- readTextFile (showcaseOutputDirectory <> "/samples/northstar-cloud/index.html")
  productProof <- readTextFile (showcaseOutputDirectory <> "/samples/northstar-cloud/proof.html")
  productRollout <- readTextFile (showcaseOutputDirectory <> "/samples/northstar-cloud/rollout.html")
  productArtwork <- readTextFile (showcaseOutputDirectory <> "/samples/northstar-cloud/assets/operations-map.svg")
  atelierCaseStudy <- readTextFile (showcaseOutputDirectory <> "/samples/atelier-north/case-study.html")
  profileHome <- readTextFile (showcaseOutputDirectory <> "/samples/mina-arai/index.html")
  profileCaseStudy <- readTextFile (showcaseOutputDirectory <> "/samples/mina-arai/work/harbor-clinic.html")
  profileArtwork <- readTextFile (showcaseOutputDirectory <> "/samples/mina-arai/assets/profile-portrait.svg")
  summitHome <- readTextFile (showcaseOutputDirectory <> "/samples/signal-summit/index.html")
  summitSchedule <- readTextFile (showcaseOutputDirectory <> "/samples/signal-summit/schedule.html")
  journalEssay <- readTextFile (showcaseOutputDirectory <> "/samples/field-notes/essay/making-quiet-tools.html")
  productStylesheet <- readTextFile (showcaseOutputDirectory <> "/samples/northstar-cloud/assets/portico.css")
  atelierStylesheet <- readTextFile (showcaseOutputDirectory <> "/samples/atelier-north/assets/portico.css")
  profileStylesheet <- readTextFile (showcaseOutputDirectory <> "/samples/mina-arai/assets/portico.css")
  staleRootGuideExists <- pathExists (showcaseOutputDirectory <> "/guide/getting-started.html")
  assert "showcase home should advertise the sample lab" (contains (Pattern "Portico Sample Lab") showcaseHome)
  assert "showcase home should explain the new sample navigation pattern" (contains (Pattern "Every sample keeps an explicit Overview route in the header") showcaseHome)
  assert "showcase home should link to the preset catalog" (contains (Pattern "href=\"presets.html\"") showcaseHome)
  assert "showcase home should link to the docs sample" (contains (Pattern "href=\"samples/northline-docs/index.html\"") showcaseHome)
  assert "showcase home should link to the product sample" (contains (Pattern "href=\"samples/northstar-cloud/index.html\"") showcaseHome)
  assert "showcase home should link to the atelier sample" (contains (Pattern "href=\"samples/atelier-north/index.html\"") showcaseHome)
  assert "showcase home should link to the profile sample" (contains (Pattern "href=\"samples/mina-arai/index.html\"") showcaseHome)
  assert "preset catalog should explain intent-first selection" (contains (Pattern "Pick a preset by intent, not by accent.") showcasePresets)
  assert "preset catalog should describe the official presets" (contains (Pattern "SignalPaper") showcasePresets)
  assert "preset catalog should link to the signal summit sample" (contains (Pattern "href=\"samples/signal-summit/index.html\"") showcasePresets)
  assert "preset catalog should render the new official theme configuration code sample" (contains (Pattern "officialThemeWith") showcasePresets)
  assert "preset catalog should mention officialThemeOptions in the customization ladder" (contains (Pattern "officialThemeOptions") showcasePresets)
  assert "showcase root stylesheet should reflect palette injection" (contains (Pattern "--accent:#9a3412") showcaseStylesheet)
  assert "docs sample should still resolve its concepts route locally" (contains (Pattern "href=\"concepts.html\"") docsSampleHome)
  assert "docs sample should expose the sample lab in primary navigation" (contains (Pattern "href=\"../../index.html\">Sample Lab</a>") docsSampleHome)
  assert "product sample should render the landing quote" (contains (Pattern "Northstar replaced three disconnected launch checklists") productSampleHome)
  assert "product sample should render FAQ content" (contains (Pattern "Can we keep our existing docs URLs?") productSampleHome)
  assert "product sample should render site image content" (contains (Pattern "src=\"assets/operations-map.svg\"") productSampleHome)
  assert "product sample should include the continue exploring section" (contains (Pattern "Continue exploring") productSampleHome)
  assert "product sample should link sideways to another sample" (contains (Pattern "href=\"../atelier-north/index.html\"") productSampleHome)
  assert "product proof should render the testimonial attribution" (contains (Pattern "Mara Singh, launch manager at Transit Layer") productProof)
  assert "product proof should resolve the rollout link locally" (contains (Pattern "href=\"rollout.html\"") productProof)
  assert "product rollout should render code sample content" (contains (Pattern "launch_owner: editorial-platform") productRollout)
  assert "product artwork should emit an svg file" (contains (Pattern "<svg") productArtwork)
  assert "atelier sample should render metrics content" (contains (Pattern "38%") atelierCaseStudy)
  assert "atelier sample should render metric labels under the values" (contains (Pattern "faster orientation") atelierCaseStudy)
  assert "atelier sample should render timeline content" (contains (Pattern "Week 3: Rebuild the information spine") atelierCaseStudy)
  assert "profile sample should render collaborator roster content" (contains (Pattern "Ryo Matsuda") profileHome)
  assert "profile sample should render site image content" (contains (Pattern "src=\"assets/profile-portrait.svg\"") profileHome)
  assert "profile sample should render the nested case study" (contains (Pattern "Harbor Clinic Service Redesign") profileCaseStudy)
  assert "profile case study should link back to the profile relatively" (contains (Pattern "href=\"../index.html\"") profileCaseStudy)
  assert "profile case study should link back to the sample lab via the collection helper" (contains (Pattern "href=\"../../../index.html\"") profileCaseStudy)
  assert "profile case study should include the explicit overview wayfinding card" (contains (Pattern "Back to this sample overview") profileCaseStudy)
  assert "profile case study should link sideways to another sample from the wayfinding section" (contains (Pattern "href=\"../../signal-summit/index.html\"") profileCaseStudy)
  assert "profile artwork should emit an svg file" (contains (Pattern "<svg") profileArtwork)
  assert "summit sample should render speaker roster content" (contains (Pattern "Nadia Vale") summitHome)
  assert "summit sample should render schedule meta" (contains (Pattern "09:00") summitSchedule)
  assert "summit sample should render FAQ content" (contains (Pattern "Will session recordings be published?") summitSchedule)
  assert "journal sample should render publication prose" (contains (Pattern "Quiet tools do not compete for attention") journalEssay)
  assert "journal sample should render notebook trail timeline" (contains (Pattern "Draft 3") journalEssay)
  assert "product stylesheet should include FAQ styles" (contains (Pattern ".faq-item") productStylesheet)
  assert "product stylesheet should include quote styles" (contains (Pattern ".quote-body") productStylesheet)
  assert "product stylesheet should include image styles" (contains (Pattern ".image-block") productStylesheet)
  assert "product stylesheet should reflect accent-derived palette injection" (contains (Pattern "--background:color-mix(in srgb,#0f766e 5%,#f6f1e8)") productStylesheet)
  assert "product stylesheet should reflect spacing customization" (contains (Pattern "--hero-padding:2.35rem") productStylesheet)
  assert "product stylesheet should reflect surface customization" (contains (Pattern "--frame-width:74rem") productStylesheet)
  assert "atelier stylesheet should include metric styles" (contains (Pattern ".metric-value") atelierStylesheet)
  assert "atelier stylesheet should reflect preset spacing" (contains (Pattern "--section-gap:2.7rem") atelierStylesheet)
  assert "atelier stylesheet should reflect preset chrome" (contains (Pattern "--pill-radius:0.55rem") atelierStylesheet)
  assert "profile stylesheet should include people styles" (contains (Pattern ".person-card") profileStylesheet)
  assert "profile stylesheet should reflect accent-derived theme customization" (contains (Pattern "--accent:#c2410c") profileStylesheet)
  assert "profile stylesheet should reflect card spacing customization" (contains (Pattern "--card-padding:1.45rem") profileStylesheet)
  assert "profile stylesheet should reflect surface customization" (contains (Pattern "--frame-width:66rem") profileStylesheet)
  assert "showcase build should clear stale root pages" (not staleRootGuideExists)

  removeTree publicOutputDirectory
  buildPublicSite publicOutputDirectory
  publicHome <- readTextFile (publicOutputDirectory <> "/index.html")
  publicGuide <- readTextFile (publicOutputDirectory <> "/guide/getting-started.html")
  publicLabHome <- readTextFile (publicOutputDirectory <> "/lab/index.html")
  publicLabPresets <- readTextFile (publicOutputDirectory <> "/lab/presets.html")
  publicSampleHome <- readTextFile (publicOutputDirectory <> "/samples/northstar-cloud/index.html")
  publicSampleNested <- readTextFile (publicOutputDirectory <> "/samples/mina-arai/work/harbor-clinic.html")
  assert "public home should use the official site root" (contains (Pattern "Build published static sites in PureScript.") publicHome)
  assert "public guide should link back to the sample lab relatively" (contains (Pattern "href=\"../lab/index.html\"") publicGuide)
  assert "public lab should link back to the official site" (contains (Pattern "href=\"../index.html\">Official Site</a>") publicLabHome)
  assert "public lab should keep the preset catalog local to the mounted lab" (contains (Pattern "href=\"presets.html\"") publicLabHome)
  assert "public preset catalog should link to root-mounted samples" (contains (Pattern "href=\"../samples/signal-summit/index.html\"") publicLabPresets)
  assert "public sample home should link back to the mounted sample lab" (contains (Pattern "href=\"../../lab/index.html\">Sample Lab</a>") publicSampleHome)
  assert "public sample home should link back to the official site" (contains (Pattern "href=\"../../index.html\">Official Site</a>") publicSampleHome)
  assert "public nested sample page should link back to the mounted sample lab" (contains (Pattern "href=\"../../../lab/index.html\"") publicSampleNested)
  assert "public nested sample page should link back to the official site" (contains (Pattern "href=\"../../../index.html\">Official Site</a>") publicSampleNested)

  removeTree pagesOutputDirectory
  buildPublicSiteWithConfig { baseUrl: Just "https://masaya.github.io/portico/" } pagesOutputDirectory
  pagesHome <- readTextFile (pagesOutputDirectory <> "/index.html")
  pagesLab <- readTextFile (pagesOutputDirectory <> "/lab/index.html")
  pagesSample <- readTextFile (pagesOutputDirectory <> "/samples/northstar-cloud/index.html")
  pages404 <- readTextFile (pagesOutputDirectory <> "/404.html")
  pagesRobots <- readTextFile (pagesOutputDirectory <> "/robots.txt")
  pagesSitemap <- readTextFile (pagesOutputDirectory <> "/sitemap.xml")
  assert "pages build should emit a canonical url on the official home page" (contains (Pattern "rel=\"canonical\" href=\"https://masaya.github.io/portico/index.html\"") pagesHome)
  assert "pages build should emit a canonical url on the mounted sample lab" (contains (Pattern "rel=\"canonical\" href=\"https://masaya.github.io/portico/lab/index.html\"") pagesLab)
  assert "pages build should emit a canonical url on mounted sample pages" (contains (Pattern "rel=\"canonical\" href=\"https://masaya.github.io/portico/samples/northstar-cloud/index.html\"") pagesSample)
  assert "pages build should emit a dedicated 404 page" (contains (Pattern "This route does not exist.") pages404)
  assert "pages build should link the 404 page back to the mounted sample lab" (contains (Pattern "href=\"lab/index.html\"") pages404)
  assert "pages build should emit robots.txt" (contains (Pattern "User-agent: *") pagesRobots)
  assert "pages build should include a sitemap reference in robots.txt" (contains (Pattern "Sitemap: https://masaya.github.io/portico/sitemap.xml") pagesRobots)
  assert "pages build should emit sitemap.xml" (contains (Pattern "<urlset") pagesSitemap)
  assert "pages build sitemap should include the official home page" (contains (Pattern "<loc>https://masaya.github.io/portico/index.html</loc>") pagesSitemap)
  assert "pages build sitemap should include the mounted sample lab" (contains (Pattern "<loc>https://masaya.github.io/portico/lab/index.html</loc>") pagesSitemap)
  assert "pages build sitemap should include nested sample pages" (contains (Pattern "<loc>https://masaya.github.io/portico/samples/mina-arai/work/harbor-clinic.html</loc>") pagesSitemap)

assert :: String -> Boolean -> Effect Unit
assert message condition =
  if condition then
    pure unit
  else
    throw message

hasDiagnostic :: ValidationSeverity -> ValidationCode -> Array ValidationDiagnostic -> Boolean
hasDiagnostic severity code =
  Array.any (\diagnostic -> diagnostic.severity == severity && diagnostic.code == code)

expectRenderedPage :: String -> Array RenderedPage -> RenderedPage
expectRenderedPage path renderedPages =
  case Array.find (\renderedPage -> renderedPage.path == path) renderedPages of
    Just renderedPage -> renderedPage
    Nothing -> unsafeCrashWith ("Missing rendered page at path: " <> path)

invalidSite :: Site
invalidSite =
  withNavigation
    [ siteNavItem "Broken route" "missing.html"
    , siteNavItem "" "guide.html"
    ]
    (site
      "Broken Portico"
      [ page
          "guide"
          Documentation
          "Guide"
          [ withSectionId
              "duplicate-anchor"
              (namedSection
                "Intro"
                [ ProseBlock "This section intentionally hides the hero behind prose."
                , HeroBlock (hero "Late hero" "This hero is intentionally misplaced to test validation.")
                , LinkGridBlock
                    [ slugLinkCard "Broken release link" "missing-release" Nothing
                    , slugLinkCard "" "guide" Nothing
                    ]
                ])
          , withSectionId
              "duplicate-anchor"
              (namedSection "Empty section" [])
          ]
      , page
          "guide"
          Documentation
          ""
          []
      ])

metadataSite :: Site
metadataSite =
  withBaseUrl "https://example.com/portico"
    (withDefaultSocialImage
      (ExternalAsset "https://cdn.example.com/portico-card.png")
      (withDescription
        "Metadata-ready public surfaces in PureScript."
        (site
          "Meta Portico"
          [ page
              "index"
              Landing
              "Meta Portico"
              [ namedSection
                  "Front door"
                  [ HeroBlock (hero "Metadata ready" "Canonical, OG, and Twitter metadata should render from the site model.")
                  ]
              ]
          , withSocialImage
              (SiteAsset "assets/guide-card.svg")
              (withSummary
                "A focused page for metadata coverage."
                (page
                  "guide/metadata"
                  Documentation
                  "Metadata Guide"
                  [ namedSection
                      "Details"
                      [ ProseBlock "This page exists to verify metadata rendering." ]
                  ]))
          ])))

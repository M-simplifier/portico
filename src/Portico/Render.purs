module Portico.Render
  ( RenderedPage
  , RenderedAsset
  , RenderedSite
  , pageOutputPath
  , renderLocalizedSite
  , renderMountedLocalizedSite
  , renderPage
  , renderMountedSite
  , renderSite
  , renderStaticSite
  , renderStylesheet
  ) where

import Prelude

import Data.Array as Array
import Data.Foldable (foldMap)
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Portico.Site (AssetTarget(..), Block(..), CalloutTone(..), LinkCard, LinkTarget(..), Locale, LocalizedSite, LocalizedVariant, NavItem, Page, PageKind(..), Section, Site, SiteLabels, localeCode, pageKey, pagePath)
import Portico.Theme (Theme)

type RenderedPage =
  { path :: String
  , title :: String
  , html :: String
  }

type RenderedAsset =
  { path :: String
  , content :: String
  }

type RenderedSite =
  { pages :: Array RenderedPage
  , assets :: Array RenderedAsset
  }

type RouteContext =
  { siteRootPath :: String
  , currentOutputPath :: String
  }

type LocaleLink =
  { locale :: Locale
  , label :: String
  , href :: String
  , absoluteHref :: Maybe String
  , current :: Boolean
  }

type LocalizationContext =
  { links :: Array LocaleLink
  , defaultHrefAbsolute :: Maybe String
  }

data StyleStrategy
  = InlineStyles
  | LinkedStylesheet String

renderSite :: Theme -> Site -> Array RenderedPage
renderSite currentTheme currentSite =
  map (renderPageAtMount "" currentTheme currentSite) currentSite.pages

renderPage :: Theme -> Site -> Page -> RenderedPage
renderPage = renderPageAtMount ""

renderStaticSite :: String -> Theme -> Site -> RenderedSite
renderStaticSite = renderMountedSite ""

renderLocalizedSite :: String -> Theme -> LocalizedSite -> RenderedSite
renderLocalizedSite = renderMountedLocalizedSite ""

renderMountedLocalizedSite :: String -> String -> Theme -> LocalizedSite -> RenderedSite
renderMountedLocalizedSite collectionMount stylesheetPath currentTheme currentLocalizedSite =
  let
    renderedVariants =
      map (renderLocalizedVariant collectionMount stylesheetPath currentTheme currentLocalizedSite) currentLocalizedSite.variants
  in
    { pages: foldMap _.pages renderedVariants
    , assets: foldMap _.assets renderedVariants
    }

renderMountedSite :: String -> String -> Theme -> Site -> RenderedSite
renderMountedSite mountPath stylesheetPath currentTheme currentSite =
  { pages: map (renderPageWithStylesheetAtMount mountPath stylesheetPath currentTheme currentSite) currentSite.pages
  , assets:
      [ { path: mountedPath mountPath stylesheetPath
        , content: renderStylesheetForSite currentSite currentTheme
        }
      ]
  }

pageOutputPath :: Page -> String
pageOutputPath = pagePath

documentTitle :: String -> String -> String
documentTitle siteTitle pageTitle
  | pageTitle == siteTitle = siteTitle
  | otherwise = pageTitle <> " | " <> siteTitle

renderDocument :: RouteContext -> Maybe LocalizationContext -> StyleStrategy -> Theme -> Site -> Page -> String
renderDocument routeContext localizationContext styleStrategy currentTheme currentSite currentPage =
  let
    currentDocumentTitle = documentTitle currentSite.title currentPage.title
  in
  joinWith ""
    [ "<!doctype html>"
    , "<html lang=\""
    , escapeHtml (htmlLanguage currentSite)
    , "\">"
    , "<head>"
    , "<meta charset=\"utf-8\">"
    , "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
    , renderMetaDescription currentSite currentPage
    , renderCanonicalLink routeContext currentSite
    , renderAlternateLinks localizationContext
    , renderSocialMetadata routeContext currentSite currentPage currentDocumentTitle
    , "<title>"
    , escapeHtml currentDocumentTitle
    , "</title>"
    , renderHeadStyles styleStrategy currentSite currentTheme
    , "</head>"
    , "<body>"
    , "<a class=\"skip-link\" href=\"#main-content\">"
    , escapeHtml currentSite.labels.skipToContent
    , "</a>"
    , "<div class=\"page-shell\">"
    , renderSiteHeader routeContext localizationContext currentSite
    , "<main id=\"main-content\" class=\"page-main\">"
    , renderPageIntro currentSite currentPage
    , foldMap (renderSection routeContext currentSite currentPage) currentPage.sections
    , "</main>"
    , renderSiteFooter currentSite
    , "</div>"
    , "</body>"
    , "</html>"
    ]

renderPageAtMount :: String -> Theme -> Site -> Page -> RenderedPage
renderPageAtMount mountPath currentTheme currentSite currentPage =
  let
    routeContext = pageRouteContext mountPath currentPage
  in
    { path: routeContext.currentOutputPath
    , title: documentTitle currentSite.title currentPage.title
    , html: renderDocument routeContext Nothing InlineStyles currentTheme currentSite currentPage
    }

renderPageWithStylesheetAtMount :: String -> String -> Theme -> Site -> Page -> RenderedPage
renderPageWithStylesheetAtMount mountPath stylesheetPath currentTheme currentSite currentPage =
  let
    routeContext = pageRouteContext mountPath currentPage
    stylesheetOutputPath = mountedPath mountPath stylesheetPath
  in
    { path: routeContext.currentOutputPath
    , title: documentTitle currentSite.title currentPage.title
    , html:
        renderDocument
          routeContext
          Nothing
          (LinkedStylesheet (relativeHref routeContext.currentOutputPath stylesheetOutputPath))
          currentTheme
          currentSite
          currentPage
    }

renderLocalizedVariant :: String -> String -> Theme -> LocalizedSite -> LocalizedVariant -> RenderedSite
renderLocalizedVariant collectionMount stylesheetPath currentTheme currentLocalizedSite currentVariant =
  let
    mountPath = localizedVariantMountPath collectionMount currentVariant
  in
    { pages:
        map
          (renderLocalizedPageWithStylesheetAtMount collectionMount mountPath stylesheetPath currentTheme currentLocalizedSite currentVariant)
          currentVariant.site.pages
    , assets:
        [ { path: mountedPath mountPath stylesheetPath
          , content: renderStylesheetForSite currentVariant.site currentTheme
          }
        ]
    }

renderLocalizedPageWithStylesheetAtMount :: String -> String -> String -> Theme -> LocalizedSite -> LocalizedVariant -> Page -> RenderedPage
renderLocalizedPageWithStylesheetAtMount collectionMount mountPath stylesheetPath currentTheme currentLocalizedSite currentVariant currentPage =
  let
    routeContext = pageRouteContext mountPath currentPage
    stylesheetOutputPath = mountedPath mountPath stylesheetPath
    localizationContext = localizedPageContext collectionMount currentLocalizedSite currentVariant currentPage
  in
    { path: routeContext.currentOutputPath
    , title: documentTitle currentVariant.site.title currentPage.title
    , html:
        renderDocument
          routeContext
          (Just localizationContext)
          (LinkedStylesheet (relativeHref routeContext.currentOutputPath stylesheetOutputPath))
          currentTheme
          currentVariant.site
          currentPage
    }

renderHeadStyles :: StyleStrategy -> Site -> Theme -> String
renderHeadStyles styleStrategy currentSite currentTheme =
  case styleStrategy of
    InlineStyles ->
      "<style>" <> renderStylesheetForSite currentSite currentTheme <> "</style>"
    LinkedStylesheet href ->
      "<link rel=\"stylesheet\" href=\"" <> escapeHtml href <> "\">"

renderMetaDescription :: Site -> Page -> String
renderMetaDescription currentSite currentPage =
  case metaDescriptionContent currentSite currentPage of
    Just description ->
      renderNamedMetaTag "description" description
    Nothing ->
      ""

metaDescriptionContent :: Site -> Page -> Maybe String
metaDescriptionContent currentSite currentPage =
  case currentPage.summary of
    Just summary -> Just summary
    Nothing -> currentSite.description

renderCanonicalLink :: RouteContext -> Site -> String
renderCanonicalLink routeContext currentSite =
  case absolutePageUrl routeContext currentSite of
    Just url ->
      "<link rel=\"canonical\" href=\"" <> escapeHtml url <> "\">"
    Nothing ->
      ""

renderAlternateLinks :: Maybe LocalizationContext -> String
renderAlternateLinks maybeContext =
  case maybeContext of
    Nothing ->
      ""
    Just context ->
      joinWith ""
        (map renderAlternateLink context.links <> renderDefaultAlternateLink context.defaultHrefAbsolute)

renderAlternateLink :: LocaleLink -> String
renderAlternateLink currentLink =
  case currentLink.absoluteHref of
    Just href ->
      "<link rel=\"alternate\" hreflang=\""
        <> escapeHtml (localeCode currentLink.locale)
        <> "\" href=\""
        <> escapeHtml href
        <> "\">"
    Nothing ->
      ""

renderDefaultAlternateLink :: Maybe String -> Array String
renderDefaultAlternateLink maybeHref =
  case maybeHref of
    Just href ->
      [ "<link rel=\"alternate\" hreflang=\"x-default\" href=\"" <> escapeHtml href <> "\">" ]
    Nothing ->
      []

renderSocialMetadata :: RouteContext -> Site -> Page -> String -> String
renderSocialMetadata routeContext currentSite currentPage currentDocumentTitle =
  let
    description = metaDescriptionContent currentSite currentPage
    pageUrl = absolutePageUrl routeContext currentSite
    imageUrl = socialImageUrl routeContext currentSite currentPage
    twitterCard =
      case imageUrl of
        Just _ -> "summary_large_image"
        Nothing -> "summary"
  in
    joinWith ""
      [ renderPropertyMetaTag "og:site_name" currentSite.title
      , renderPropertyMetaTag "og:title" currentDocumentTitle
      , renderPropertyMetaTag "og:type" (openGraphType currentPage.kind)
      , renderOptionalPropertyMetaTag "og:description" description
      , renderOptionalPropertyMetaTag "og:url" pageUrl
      , renderOptionalPropertyMetaTag "og:image" imageUrl
      , renderNamedMetaTag "twitter:card" twitterCard
      , renderNamedMetaTag "twitter:title" currentDocumentTitle
      , renderOptionalNamedMetaTag "twitter:description" description
      , renderOptionalNamedMetaTag "twitter:image" imageUrl
      ]

renderNamedMetaTag :: String -> String -> String
renderNamedMetaTag name content =
  "<meta name=\"" <> escapeHtml name <> "\" content=\"" <> escapeHtml content <> "\">"

renderOptionalNamedMetaTag :: String -> Maybe String -> String
renderOptionalNamedMetaTag name content =
  case content of
    Just value -> renderNamedMetaTag name value
    Nothing -> ""

renderPropertyMetaTag :: String -> String -> String
renderPropertyMetaTag property content =
  "<meta property=\"" <> escapeHtml property <> "\" content=\"" <> escapeHtml content <> "\">"

renderOptionalPropertyMetaTag :: String -> Maybe String -> String
renderOptionalPropertyMetaTag property content =
  case content of
    Just value -> renderPropertyMetaTag property value
    Nothing -> ""

renderSiteHeader :: RouteContext -> Maybe LocalizationContext -> Site -> String
renderSiteHeader routeContext localizationContext currentSite =
  joinWith ""
    [ "<header class=\"site-header\">"
    , "<div class=\"site-header-inner\">"
    , "<a class=\"site-brand\" href=\""
    , resolveTarget routeContext (SitePath "index.html")
    , "\">"
    , "<span class=\"site-brand-mark\">"
    , initials currentSite.title
    , "</span>"
    , "<span class=\"site-brand-copy\">"
    , "<strong>"
    , escapeHtml currentSite.title
    , "</strong>"
    , renderOptionalParagraph "site-description" currentSite.description
    , "</span>"
    , "</a>"
    , "<div class=\"site-header-actions\">"
    , renderNavigation routeContext currentSite
    , renderLocaleSwitcher localizationContext currentSite
    , "</div>"
    , "</div>"
    , "</header>"
    ]

renderNavigation :: RouteContext -> Site -> String
renderNavigation routeContext currentSite =
  case currentSite.navigation of
    [] -> ""
    navigation ->
      joinWith ""
        [ "<nav class=\"site-nav\" aria-label=\""
        , escapeHtml currentSite.labels.primaryNavigation
        , "\">"
        , foldMap (renderNavItem routeContext) navigation
        , "</nav>"
        ]

renderLocaleSwitcher :: Maybe LocalizationContext -> Site -> String
renderLocaleSwitcher maybeContext currentSite =
  case maybeContext of
    Just context ->
      if Array.length context.links > 1 then
        joinWith ""
          [ "<nav class=\"locale-switch\" aria-label=\""
          , escapeHtml currentSite.labels.localeNavigation
          , "\">"
          , foldMap renderLocaleLink context.links
          , "</nav>"
          ]
      else
        ""
    Nothing ->
      ""

renderLocaleLink :: LocaleLink -> String
renderLocaleLink currentLink =
  joinWith ""
    [ "<a class=\"locale-switch-link"
    , if currentLink.current then " locale-switch-link-current" else ""
    , "\" href=\""
    , escapeHtml currentLink.href
    , "\""
    , if currentLink.current then " aria-current=\"page\"" else ""
    , ">"
    , escapeHtml currentLink.label
    , "</a>"
    ]

renderNavItem :: RouteContext -> NavItem -> String
renderNavItem routeContext item =
  joinWith ""
    [ "<a class=\"site-nav-link"
    , if isCurrentNavItem routeContext item then " site-nav-link-current" else ""
    , "\" href=\""
    , escapeHtml (resolveTarget routeContext item.target)
    , "\""
    , if isCurrentNavItem routeContext item then " aria-current=\"page\"" else ""
    , ">"
    , escapeHtml item.label
    , "</a>"
    ]

renderPageIntro :: Site -> Page -> String
renderPageIntro currentSite currentPage =
  if hasLeadHero currentPage then
    ""
  else
    joinWith ""
      [ "<header class=\"page-intro\">"
      , "<p class=\"page-kind\">"
      , escapeHtml (pageKindLabel currentSite.labels currentPage.kind)
      , "</p>"
      , "<h1>"
      , escapeHtml currentPage.title
      , "</h1>"
      , renderOptionalParagraph "page-summary" currentPage.summary
      , "</header>"
      ]

renderSection :: RouteContext -> Site -> Page -> Section -> String
renderSection routeContext currentSite currentPage currentSection =
  joinWith ""
    [ "<section"
    , renderSectionId currentSection
    , " class=\""
    , joinWith " " (["content-section"] <> sectionClasses currentSection)
    , "\">"
    , renderSectionHeader currentSection
    , "<div class=\"section-stack\">"
    , foldMap (renderBlock routeContext currentSite currentPage) currentSection.blocks
    , "</div>"
    , "</section>"
    ]

sectionClasses :: Section -> Array String
sectionClasses currentSection =
  (if hasSectionHero currentSection then ["content-section-lead"] else [])
    <> (if hasSectionHero currentSection && Array.length currentSection.blocks > 1 then ["content-section-composite"] else [])
    <> (if hasSectionMetrics currentSection then ["content-section-metrics"] else [])
    <> (if hasSectionCode currentSection then ["content-section-code"] else [])

hasSectionHero :: Section -> Boolean
hasSectionHero currentSection =
  Array.any isHeroBlock currentSection.blocks

hasSectionMetrics :: Section -> Boolean
hasSectionMetrics currentSection =
  Array.any isMetricsBlock currentSection.blocks

hasSectionCode :: Section -> Boolean
hasSectionCode currentSection =
  Array.any isCodeBlock currentSection.blocks

isHeroBlock :: Block -> Boolean
isHeroBlock = case _ of
  HeroBlock _ -> true
  _ -> false

isMetricsBlock :: Block -> Boolean
isMetricsBlock = case _ of
  MetricsBlock _ -> true
  _ -> false

isCodeBlock :: Block -> Boolean
isCodeBlock = case _ of
  CodeBlock _ -> true
  _ -> false

renderSectionId :: Section -> String
renderSectionId currentSection =
  case currentSection.id of
    Just value -> " id=\"" <> escapeHtml value <> "\""
    Nothing -> ""

renderSectionHeader :: Section -> String
renderSectionHeader currentSection =
  case currentSection.label of
    Just label ->
      "<header class=\"section-header\"><h2>" <> escapeHtml label <> "</h2></header>"
    Nothing ->
      ""

renderBlock :: RouteContext -> Site -> Page -> Block -> String
renderBlock routeContext currentSite currentPage = case _ of
  HeroBlock currentHero ->
    joinWith ""
      [ "<article class=\"hero-block block-card\">"
      , renderHeroEyebrow currentSite currentPage currentHero.eyebrow
      , "<h1>"
      , escapeHtml currentHero.title
      , "</h1>"
      , "<p class=\"hero-body\">"
      , escapeHtml currentHero.body
      , "</p>"
      , renderHeroActions routeContext currentSite currentHero.actions
      , "</article>"
      ]
  ProseBlock body ->
    "<article class=\"prose-block block-card\"><p>" <> escapeHtml body <> "</p></article>"
  FeatureGridBlock features ->
    joinWith ""
      [ "<div class=\"feature-grid\">"
      , foldMap renderFeature features
      , "</div>"
      ]
  MetricsBlock metrics ->
    joinWith ""
      [ "<div class=\"metric-grid\">"
      , foldMap renderMetric metrics
      , "</div>"
      ]
  TimelineBlock entries ->
    joinWith ""
      [ "<div class=\"timeline\">"
      , foldMap renderTimelineEntry entries
      , "</div>"
      ]
  CodeBlock sample ->
    renderCodeSample sample
  ImageBlock currentImage ->
    renderImage routeContext currentImage
  PeopleBlock people ->
    joinWith ""
      [ "<div class=\"people-grid\">"
      , foldMap renderPerson people
      , "</div>"
      ]
  QuoteBlock currentQuote ->
    renderQuote currentQuote
  FaqBlock entries ->
    joinWith ""
      [ "<div class=\"faq-list\">"
      , foldMap renderFaqEntry entries
      , "</div>"
      ]
  CalloutBlock currentCallout ->
    joinWith ""
      [ "<aside class=\"callout block-card "
      , calloutToneClass currentCallout.tone
      , "\">"
      , "<p class=\"callout-tone\">"
      , escapeHtml (calloutToneLabel currentSite.labels currentCallout.tone)
      , "</p>"
      , "<h3>"
      , escapeHtml currentCallout.title
      , "</h3>"
      , "<p>"
      , escapeHtml currentCallout.body
      , "</p>"
      , "</aside>"
      ]
  LinkGridBlock cards ->
    joinWith ""
      [ "<div class=\"link-grid\">"
      , foldMap (renderLinkCard routeContext currentSite) cards
      , "</div>"
      ]

renderHeroEyebrow :: Site -> Page -> Maybe String -> String
renderHeroEyebrow currentSite currentPage eyebrow =
  case eyebrow of
    Just value -> "<p class=\"hero-eyebrow\">" <> escapeHtml value <> "</p>"
    Nothing -> "<p class=\"hero-eyebrow\">" <> escapeHtml (pageKindLabel currentSite.labels currentPage.kind) <> "</p>"

renderHeroActions :: RouteContext -> Site -> Array LinkCard -> String
renderHeroActions routeContext currentSite actions =
  case actions of
    [] -> ""
    _ ->
      joinWith ""
        [ "<div class=\"hero-actions\">"
        , foldMap (renderLinkCard routeContext currentSite) actions
        , "</div>"
        ]

renderFeature :: { title :: String, body :: String } -> String
renderFeature currentFeature =
  joinWith ""
    [ "<article class=\"feature-card block-card\">"
    , "<h3>"
    , escapeHtml currentFeature.title
    , "</h3>"
    , "<p>"
    , escapeHtml currentFeature.body
    , "</p>"
    , "</article>"
    ]

renderMetric :: { label :: String, value :: String, detail :: Maybe String } -> String
renderMetric currentMetric =
  joinWith ""
    [ "<article class=\"metric-card block-card\">"
    , "<p class=\"metric-value\">"
    , escapeHtml currentMetric.value
    , "</p>"
    , "<p class=\"metric-label\">"
    , escapeHtml currentMetric.label
    , "</p>"
    , renderOptionalParagraph "metric-detail" currentMetric.detail
    , "</article>"
    ]

renderTimelineEntry :: { title :: String, body :: String, meta :: Maybe String } -> String
renderTimelineEntry currentEntry =
  joinWith ""
    [ "<article class=\"timeline-entry block-card\">"
    , renderOptionalParagraph "timeline-meta" currentEntry.meta
    , "<h3>"
    , escapeHtml currentEntry.title
    , "</h3>"
    , "<p>"
    , escapeHtml currentEntry.body
    , "</p>"
    , "</article>"
    ]

renderCodeSample :: { code :: String, language :: Maybe String, title :: Maybe String } -> String
renderCodeSample sample =
  joinWith ""
    [ "<figure class=\"code-block block-card\">"
    , renderCodeSampleHeader sample
    , "<pre><code>"
    , escapeHtml sample.code
    , "</code></pre>"
    , "</figure>"
    ]

renderCodeSampleHeader :: { code :: String, language :: Maybe String, title :: Maybe String } -> String
renderCodeSampleHeader sample =
  case sample.title, sample.language of
    Nothing, Nothing -> ""
    _, _ ->
      joinWith ""
        [ "<figcaption class=\"code-meta\">"
        , renderOptionalSpan "code-title" sample.title
        , renderOptionalSpan "code-language" sample.language
        , "</figcaption>"
        ]

renderImage :: RouteContext -> { alt :: String, source :: AssetTarget, caption :: Maybe String } -> String
renderImage routeContext currentImage =
  joinWith ""
    [ "<figure class=\"image-block block-card\">"
    , "<img src=\""
    , escapeHtml (resolveAssetTarget routeContext currentImage.source)
    , "\" alt=\""
    , escapeHtml currentImage.alt
    , "\">"
    , renderOptionalParagraph "image-caption" currentImage.caption
    , "</figure>"
    ]

renderPerson :: { name :: String, role :: String, bio :: String, detail :: Maybe String } -> String
renderPerson currentPerson =
  joinWith ""
    [ "<article class=\"person-card block-card\">"
    , "<p class=\"person-role\">"
    , escapeHtml currentPerson.role
    , "</p>"
    , "<h3 class=\"person-name\">"
    , escapeHtml currentPerson.name
    , "</h3>"
    , "<p class=\"person-bio\">"
    , escapeHtml currentPerson.bio
    , "</p>"
    , renderOptionalParagraph "person-detail" currentPerson.detail
    , "</article>"
    ]

renderQuote :: { body :: String, attribution :: String, context :: Maybe String } -> String
renderQuote currentQuote =
  joinWith ""
    [ "<figure class=\"quote-block block-card\">"
    , "<blockquote class=\"quote-body\">"
    , "<p>"
    , escapeHtml currentQuote.body
    , "</p>"
    , "</blockquote>"
    , "<figcaption class=\"quote-attribution\">"
    , "<strong>"
    , escapeHtml currentQuote.attribution
    , "</strong>"
    , renderOptionalParagraph "quote-context" currentQuote.context
    , "</figcaption>"
    , "</figure>"
    ]

renderFaqEntry :: { question :: String, answer :: String } -> String
renderFaqEntry entry =
  joinWith ""
    [ "<details class=\"faq-item block-card\">"
    , "<summary>"
    , escapeHtml entry.question
    , "</summary>"
    , "<p class=\"faq-answer\">"
    , escapeHtml entry.answer
    , "</p>"
    , "</details>"
    ]

renderLinkCard :: RouteContext -> Site -> LinkCard -> String
renderLinkCard routeContext currentSite currentCard =
  joinWith ""
    [ "<a class=\"link-card block-card\" href=\""
    , escapeHtml (resolveTarget routeContext currentCard.target)
    , "\">"
    , "<strong>"
    , escapeHtml currentCard.label
    , "</strong>"
    , renderOptionalParagraph "link-card-summary" currentCard.summary
    , "<span class=\"link-card-meta\">"
    , escapeHtml currentSite.labels.openLink
    , "</span>"
    , "</a>"
    ]

renderSiteFooter :: Site -> String
renderSiteFooter currentSite =
  joinWith ""
    [ "<footer class=\"site-footer\">"
    , "<div class=\"site-footer-inner\">"
    , "<p class=\"site-footer-title\">"
    , escapeHtml currentSite.title
    , "</p>"
    , renderOptionalParagraph "site-footer-description" currentSite.description
    , "</div>"
    , "</footer>"
    ]

renderOptionalParagraph :: String -> Maybe String -> String
renderOptionalParagraph className currentValue =
  case currentValue of
    Just value ->
      "<p class=\"" <> className <> "\">" <> escapeHtml value <> "</p>"
    Nothing ->
      ""

renderOptionalSpan :: String -> Maybe String -> String
renderOptionalSpan className currentValue =
  case currentValue of
    Just value ->
      "<span class=\"" <> className <> "\">" <> escapeHtml value <> "</span>"
    Nothing ->
      ""

hasLeadHero :: Page -> Boolean
hasLeadHero currentPage =
  case Array.head currentPage.sections of
    Just currentSection ->
      case Array.head currentSection.blocks of
        Just (HeroBlock _) -> true
        _ -> false
    Nothing ->
      false

pageKindLabel :: SiteLabels -> PageKind -> String
pageKindLabel labels = case _ of
  Landing -> labels.landingKind
  Documentation -> labels.documentationKind
  Article -> labels.articleKind
  ReleaseNotes -> labels.releaseNotesKind
  Showcase -> labels.showcaseKind
  Microsite -> labels.micrositeKind
  Profile -> labels.profileKind
  CustomKind label -> label

calloutToneClass :: CalloutTone -> String
calloutToneClass = case _ of
  Quiet -> "callout-quiet"
  Accent -> "callout-accent"
  Strong -> "callout-strong"

calloutToneLabel :: SiteLabels -> CalloutTone -> String
calloutToneLabel labels = case _ of
  Quiet -> labels.noteCallout
  Accent -> labels.highlightCallout
  Strong -> labels.importantCallout

openGraphType :: PageKind -> String
openGraphType = case _ of
  Article -> "article"
  Documentation -> "article"
  ReleaseNotes -> "article"
  _ -> "website"

resolveTarget :: RouteContext -> LinkTarget -> String
resolveTarget routeContext = case _ of
  ExternalHref href -> href
  SitePath path -> relativeHref routeContext.currentOutputPath (mountedPath routeContext.siteRootPath path)
  CollectionPath path -> relativeHref routeContext.currentOutputPath path

isCurrentNavItem :: RouteContext -> NavItem -> Boolean
isCurrentNavItem routeContext item = case item.target of
  SitePath path -> mountedPath routeContext.siteRootPath path == routeContext.currentOutputPath
  _ -> false

resolveAssetTarget :: RouteContext -> AssetTarget -> String
resolveAssetTarget routeContext = case _ of
  ExternalAsset src -> src
  SiteAsset path -> relativeHref routeContext.currentOutputPath (mountedPath routeContext.siteRootPath path)
  CollectionAsset path -> relativeHref routeContext.currentOutputPath path

resolveAbsoluteAssetTarget :: RouteContext -> Site -> AssetTarget -> Maybe String
resolveAbsoluteAssetTarget routeContext currentSite = case _ of
  ExternalAsset src -> Just src
  SiteAsset path ->
    case currentSite.baseUrl of
      Just baseUrl -> Just (absoluteUrl baseUrl (mountedPath routeContext.siteRootPath path))
      Nothing -> Nothing
  CollectionAsset path ->
    case currentSite.baseUrl of
      Just baseUrl -> Just (absoluteUrl baseUrl path)
      Nothing -> Nothing

absolutePageUrl :: RouteContext -> Site -> Maybe String
absolutePageUrl routeContext currentSite =
  case currentSite.baseUrl of
    Just baseUrl -> Just (absoluteUrl baseUrl routeContext.currentOutputPath)
    Nothing -> Nothing

socialImageUrl :: RouteContext -> Site -> Page -> Maybe String
socialImageUrl routeContext currentSite currentPage =
  case currentPage.socialImage of
    Just socialImage -> resolveAbsoluteAssetTarget routeContext currentSite socialImage
    Nothing ->
      case currentSite.socialImage of
        Just socialImage -> resolveAbsoluteAssetTarget routeContext currentSite socialImage
        Nothing -> Nothing

absolutePageUrlAtPath :: String -> Site -> Maybe String
absolutePageUrlAtPath outputPath currentSite =
  case currentSite.baseUrl of
    Just baseUrl -> Just (absoluteUrl baseUrl outputPath)
    Nothing -> Nothing

pageRouteContext :: String -> Page -> RouteContext
pageRouteContext siteRootPath currentPage =
  { siteRootPath
  , currentOutputPath: mountedPath siteRootPath (pagePath currentPage)
  }

localizedVariantMountPath :: String -> LocalizedVariant -> String
localizedVariantMountPath collectionMount currentVariant =
  mountedPath collectionMount currentVariant.mountPath

localizedPageContext :: String -> LocalizedSite -> LocalizedVariant -> Page -> LocalizationContext
localizedPageContext currentMount currentLocalizedSite currentVariant currentPage =
  { links:
      Array.mapMaybe
        (localizedPageLink currentMount currentLocalizedSite currentVariant currentPage)
        currentLocalizedSite.variants
  , defaultHrefAbsolute: localizedDefaultHref currentMount currentLocalizedSite currentPage
  }

localizedPageLink :: String -> LocalizedSite -> LocalizedVariant -> Page -> LocalizedVariant -> Maybe LocaleLink
localizedPageLink collectionMount _ currentVariant currentPage targetVariant = do
  targetPage <- localizedPageByKey currentPage targetVariant.site
  let
    currentOutputPath = mountedPath (localizedVariantMountPath collectionMount currentVariant) (pagePath currentPage)
    targetOutputPath = mountedPath (localizedVariantMountPath collectionMount targetVariant) (pagePath targetPage)
  pure
    { locale: targetVariant.locale
    , label: targetVariant.label
    , href: relativeHref currentOutputPath targetOutputPath
    , absoluteHref: absolutePageUrlAtPath targetOutputPath targetVariant.site
    , current: targetVariant.locale == currentVariant.locale
    }

localizedDefaultHref :: String -> LocalizedSite -> Page -> Maybe String
localizedDefaultHref currentMount currentLocalizedSite currentPage = do
  defaultVariant <- Array.find (\currentVariant -> currentVariant.locale == currentLocalizedSite.defaultLocale) currentLocalizedSite.variants
  defaultPage <- localizedPageByKey currentPage defaultVariant.site
  absolutePageUrlAtPath
    (mountedPath (localizedVariantMountPath currentMount defaultVariant) (pagePath defaultPage))
    defaultVariant.site

localizedPageByKey :: Page -> Site -> Maybe Page
localizedPageByKey currentPage currentSite =
  Array.find (\candidatePage -> pageKey candidatePage == pageKey currentPage) currentSite.pages

htmlLanguage :: Site -> String
htmlLanguage currentSite =
  case currentSite.locale of
    Just currentLocale -> localeCode currentLocale
    Nothing -> "en"

mountedPath :: String -> String -> String
mountedPath prefix path
  | prefix == "" = path
  | path == "" = prefix
  | otherwise = prefix <> "/" <> path

initials :: String -> String
initials title =
  if title == "" then
    "P"
  else
    unsafeTake 2 title

foreign import unsafeTake :: Int -> String -> String
foreign import escapeHtml :: String -> String
foreign import absoluteUrl :: String -> String -> String
foreign import relativeHref :: String -> String -> String

renderStylesheet :: Theme -> String
renderStylesheet currentTheme =
  renderStylesheetWithImports [englishOfficialFontImport] currentTheme

renderStylesheetForSite :: Site -> Theme -> String
renderStylesheetForSite currentSite currentTheme =
  renderStylesheetWithImports (stylesheetImportsForSite currentSite) currentTheme

stylesheetImportsForSite :: Site -> Array String
stylesheetImportsForSite currentSite =
  [ englishOfficialFontImport ]
    <> case currentSite.locale of
        Just currentLocale | localeCode currentLocale == "ja" -> [japaneseOfficialFontImport]
        _ -> []

englishOfficialFontImport :: String
englishOfficialFontImport =
  "@import url(\"https://fonts.googleapis.com/css2?family=Fraunces:wght@600;700&family=IBM+Plex+Mono:wght@400;500;600&family=Newsreader:wght@600;700&family=Public+Sans:wght@400;500;600;700&family=Source+Serif+4:wght@400;600;700&family=Space+Grotesk:wght@500;700&display=swap\");"

japaneseOfficialFontImport :: String
japaneseOfficialFontImport =
  "@import url(\"https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;500;600;700&family=Noto+Serif+JP:wght@600;700&display=swap\");"

renderStylesheetWithImports :: Array String -> Theme -> String
renderStylesheetWithImports imports currentTheme =
  joinWith ""
    ( imports <>
    [ ":root{"
    , "--background:"
    , currentTheme.palette.background
    , ";--panel:"
    , currentTheme.palette.panel
    , ";--text:"
    , currentTheme.palette.text
    , ";--muted:"
    , currentTheme.palette.mutedText
    , ";--accent:"
    , currentTheme.palette.accent
    , ";--border:"
    , currentTheme.palette.border
    , ";--page-inset:"
    , currentTheme.spacing.pageInset
    , ";--page-top:"
    , currentTheme.spacing.pageTop
    , ";--page-bottom:"
    , currentTheme.spacing.pageBottom
    , ";--section-gap:"
    , currentTheme.spacing.sectionGap
    , ";--stack-gap:"
    , currentTheme.spacing.stackGap
    , ";--card-padding:"
    , currentTheme.spacing.cardPadding
    , ";--hero-padding:"
    , currentTheme.spacing.heroPadding
    , ";--frame-width:"
    , currentTheme.surface.frameWidth
    , ";--brand-radius:"
    , currentTheme.surface.brandRadius
    , ";--pill-radius:"
    , currentTheme.surface.pillRadius
    , ";--header-surface:"
    , currentTheme.surface.headerSurface
    , ";--hero-surface:"
    , currentTheme.surface.heroSurface
    , ";--quote-surface:"
    , currentTheme.surface.quoteSurface
    , ";--display-font:"
    , currentTheme.typography.display
    , ";--body-font:"
    , currentTheme.typography.body
    , ";--mono-font:"
    , currentTheme.typography.mono
    , ";--radius:"
    , currentTheme.radius
    , ";--shadow:"
    , currentTheme.shadow
    , ";}"
    , "*,*::before,*::after{box-sizing:border-box;}"
    , "html{scroll-behavior:smooth;}"
    , "body{margin:0;color:var(--text);font-family:var(--body-font);line-height:1.65;background:linear-gradient(180deg,color-mix(in srgb,var(--accent) 5%,white) 0%,var(--background) 16%,#ffffff 100%);}"
    , "body::before{content:\"\";position:fixed;inset:0;background:radial-gradient(circle at 12% 0%,color-mix(in srgb,var(--accent) 15%,transparent) 0%,transparent 34%),radial-gradient(circle at 88% 12%,color-mix(in srgb,var(--accent) 10%,transparent) 0%,transparent 28%),linear-gradient(180deg,color-mix(in srgb,var(--accent) 3%,white) 0%,transparent 40%);pointer-events:none;z-index:-2;}"
    , "body::after{content:\"\";position:fixed;inset:0;background-image:linear-gradient(color-mix(in srgb,var(--border) 45%,transparent) 1px,transparent 1px),linear-gradient(90deg,color-mix(in srgb,var(--border) 45%,transparent) 1px,transparent 1px);background-size:3.4rem 3.4rem;mask-image:linear-gradient(180deg,rgba(0,0,0,0.42) 0%,rgba(0,0,0,0) 68%);opacity:0.24;pointer-events:none;z-index:-1;}"
    , "a{color:inherit;text-decoration:none;}"
    , "img{max-width:100%;}"
    , "code{font-family:var(--mono-font);}"
    , ".skip-link{position:absolute;left:1rem;top:-3rem;padding:0.75rem 1rem;background:var(--text);color:var(--panel);border-radius:var(--pill-radius);box-shadow:0 16px 36px rgba(15,23,42,0.2);z-index:30;}"
    , ".skip-link:focus{top:1rem;}"
    , ".page-shell{min-height:100vh;padding:1rem 0 1.5rem;}"
    , ".site-header{position:sticky;top:0;z-index:20;padding:0 1rem;}"
    , ".site-header-inner,.page-main,.site-footer{width:min(var(--frame-width),calc(100% - var(--page-inset)));margin:0 auto;}"
    , ".site-header-inner{display:flex;align-items:center;justify-content:space-between;gap:1.5rem;padding:0.95rem 1.2rem;margin-top:0.8rem;border:1px solid color-mix(in srgb,var(--border) 80%,transparent);border-radius:calc(var(--radius) * 0.8);background:var(--header-surface);backdrop-filter:blur(18px);box-shadow:0 18px 48px rgba(15,23,42,0.08);}"
    , ".site-brand{display:flex;align-items:center;gap:1rem;min-width:0;}"
    , ".site-brand-mark{display:grid;place-items:center;width:2.65rem;height:2.65rem;border-radius:var(--brand-radius);background:linear-gradient(135deg,var(--text) 0%,color-mix(in srgb,var(--accent) 52%,var(--text)) 100%);color:white;font-family:var(--mono-font);font-size:0.78rem;letter-spacing:0.12em;text-transform:uppercase;box-shadow:0 18px 36px color-mix(in srgb,var(--accent) 18%,transparent);}"
    , ".site-brand-copy{display:grid;gap:0.2rem;min-width:0;}"
    , ".site-brand-copy strong{display:block;font-family:var(--display-font);font-size:1.15rem;font-weight:600;line-height:1;letter-spacing:-0.02em;}"
    , ".site-description{margin:0;color:var(--muted);font-size:0.92rem;max-width:28rem;}"
    , ".site-header-actions{display:flex;flex-wrap:wrap;justify-content:flex-end;align-items:center;gap:0.75rem 1rem;}"
    , ".site-nav{display:flex;flex-wrap:wrap;justify-content:flex-end;gap:0.65rem 1.15rem;}"
    , ".site-nav-link{position:relative;padding:0.35rem 0.58rem;color:var(--muted);font-size:0.96rem;font-weight:600;border-radius:var(--pill-radius);transition:background 160ms ease,color 160ms ease;}"
    , ".site-nav-link::after{content:\"\";position:absolute;left:0.6rem;right:0.6rem;bottom:0.12rem;height:2px;border-radius:999px;background:var(--accent);transform:scaleX(0);transform-origin:left;transition:transform 160ms ease;}"
    , ".site-nav-link:hover{color:var(--text);background:color-mix(in srgb,var(--accent) 7%,white);}"
    , ".site-nav-link:hover::after{transform:scaleX(1);}"
    , ".site-nav-link-current{color:var(--text);background:color-mix(in srgb,var(--accent) 10%,white);}"
    , ".site-nav-link-current::after{transform:scaleX(1);}"
    , ".locale-switch{display:flex;flex-wrap:wrap;gap:0.45rem;}"
    , ".locale-switch-link{padding:0.4rem 0.72rem;border:1px solid color-mix(in srgb,var(--border) 88%,transparent);border-radius:var(--pill-radius);background:color-mix(in srgb,var(--panel) 92%,white);font-family:var(--mono-font);font-size:0.72rem;letter-spacing:0.08em;text-transform:uppercase;color:var(--muted);}"
    , ".locale-switch-link:hover{color:var(--text);border-color:var(--accent);}"
    , ".locale-switch-link-current{color:var(--text);border-color:var(--accent);background:color-mix(in srgb,var(--accent) 8%,var(--panel));}"
    , ".page-main{padding:var(--page-top) 0 var(--page-bottom);}"
    , ".page-intro{margin-bottom:2.75rem;max-width:48rem;}"
    , ".page-kind,.hero-eyebrow,.callout-tone,.link-card-meta,.metric-label,.timeline-meta,.person-role,.quote-attribution strong,.code-title,.code-language{margin:0;font-size:0.78rem;font-family:var(--mono-font);letter-spacing:0.08em;text-transform:uppercase;color:var(--accent);}"
    , ".page-intro h1{margin:0.45rem 0 0;font-family:var(--display-font);font-size:clamp(2.8rem,5vw,4.8rem);line-height:0.95;letter-spacing:-0.04em;max-width:12.5ch;}"
    , ".hero-block h1{margin:0.35rem 0 0;font-family:var(--display-font);font-size:clamp(3.1rem,6vw,5.7rem);line-height:0.92;letter-spacing:-0.05em;max-width:11.75ch;}"
    , ".page-summary,.hero-body{max-width:42rem;font-size:1.08rem;color:var(--muted);}"
    , ".content-section + .content-section{margin-top:var(--section-gap);}"
    , ".content-section{position:relative;}"
    , ".section-header{margin-bottom:1.25rem;max-width:42rem;}"
    , ".section-header h2{margin:0;font-family:var(--display-font);font-size:clamp(1.7rem,3vw,2.35rem);line-height:1;letter-spacing:-0.03em;}"
    , ".section-stack{display:grid;gap:var(--stack-gap);}"
    , ".content-section-composite .section-stack{grid-template-columns:minmax(0,1.24fr) minmax(20rem,0.9fr);align-items:start;}"
    , ".content-section-composite .hero-block{grid-row:1 / span 2;}"
    , ".content-section-composite .metric-grid{grid-template-columns:repeat(2,minmax(0,1fr));}"
    , ".content-section-composite .code-block{min-height:100%;}"
    , ".content-section-code.content-section-composite .hero-block{grid-row:auto;}"
    , ".content-section-code.content-section-composite .code-block{grid-column:1 / -1;}"
    , ".block-card{border:1px solid color-mix(in srgb,var(--border) 82%,transparent);border-radius:var(--radius);background:color-mix(in srgb,var(--panel) 92%,white);box-shadow:0 16px 40px rgba(15,23,42,0.08);}"
    , ".hero-block{padding:var(--hero-padding);display:grid;gap:1.1rem;overflow:hidden;position:relative;background:var(--hero-surface);box-shadow:0 36px 90px rgba(15,23,42,0.16);}"
    , ".hero-block::before{content:\"\";position:absolute;right:-4rem;top:-3rem;width:18rem;height:18rem;border-radius:999px;background:radial-gradient(circle,color-mix(in srgb,var(--accent) 28%,white) 0%,transparent 72%);opacity:0.95;pointer-events:none;}"
    , ".hero-block::after{content:\"\";position:absolute;inset:auto -10% -40% 40%;height:14rem;background:linear-gradient(120deg,transparent 0%,color-mix(in srgb,var(--accent) 10%,white) 38%,transparent 72%);transform:rotate(-12deg);opacity:0.55;pointer-events:none;}"
    , ".hero-block > *{position:relative;z-index:1;}"
    , ".hero-actions,.link-grid,.feature-grid,.people-grid{display:grid;gap:1rem;grid-template-columns:repeat(auto-fit,minmax(15rem,1fr));}"
    , ".metric-grid{display:grid;gap:0.85rem;grid-template-columns:repeat(auto-fit,minmax(12rem,1fr));}"
    , ".timeline,.faq-list{display:grid;gap:1rem;}"
    , ".prose-block,.feature-card,.metric-card,.timeline-entry,.person-card,.quote-block,.callout,.link-card{padding:var(--card-padding);}"
    , ".prose-block{font-size:1.08rem;line-height:1.75;}"
    , ".prose-block,.callout{max-width:52rem;}"
    , ".prose-block p,.feature-card p,.timeline-entry p,.callout p,.link-card-summary,.metric-detail,.quote-context,.person-detail{margin:0.65rem 0 0;color:var(--muted);}"
    , ".feature-card,.link-card,.metric-card,.timeline-entry,.person-card,.faq-item,.code-block,.image-block,.quote-block,.callout{backdrop-filter:blur(6px);transition:transform 180ms ease,box-shadow 180ms ease,border-color 180ms ease;}"
    , ".feature-card{display:grid;gap:0.6rem;align-content:start;background:linear-gradient(180deg,color-mix(in srgb,var(--accent) 4%,white) 0%,color-mix(in srgb,var(--panel) 96%,white) 100%);}"
    , ".feature-card::before{content:\"\";display:block;width:2.2rem;height:0.3rem;border-radius:999px;background:color-mix(in srgb,var(--accent) 78%,white);}"
    , ".metric-card{display:grid;gap:0.45rem;align-content:start;background:linear-gradient(180deg,color-mix(in srgb,var(--accent) 6%,white) 0%,color-mix(in srgb,var(--panel) 96%,white) 100%);}"
    , ".metric-value{margin:0;font-family:var(--display-font);font-size:clamp(2rem,4vw,3rem);line-height:0.92;letter-spacing:-0.04em;}"
    , ".metric-label{margin-top:0;}"
    , ".timeline-entry{position:relative;overflow:hidden;padding-left:calc(var(--card-padding) + 0.5rem);}"
    , ".timeline-entry::before{content:\"\";position:absolute;left:0;top:0;bottom:0;width:4px;background:linear-gradient(180deg,var(--accent) 0%,color-mix(in srgb,var(--accent) 25%,transparent) 100%);}"
    , ".timeline-entry h3{margin:0;font-family:var(--display-font);font-size:1.3rem;line-height:1.05;letter-spacing:-0.02em;}"
    , ".timeline-meta{margin:0 0 0.65rem;}"
    , ".person-card{display:grid;gap:0.7rem;align-content:start;}"
    , ".person-name{margin:0;font-family:var(--display-font);font-size:1.35rem;line-height:1.05;letter-spacing:-0.02em;}"
    , ".person-bio{margin:0;color:var(--muted);}"
    , ".quote-block{display:grid;gap:1rem;background:var(--quote-surface);}"
    , ".quote-body{margin:0;}"
    , ".quote-body p{margin:0;font-family:var(--display-font);font-size:clamp(1.5rem,3vw,2.4rem);line-height:1.08;letter-spacing:-0.03em;max-width:24ch;}"
    , ".quote-attribution{margin:0;padding-top:1rem;border-top:1px solid var(--border);}"
    , ".faq-item{padding:0;overflow:hidden;}"
    , ".faq-item[open]{background:color-mix(in srgb,var(--accent) 5%,var(--panel));}"
    , ".faq-item summary{display:flex;align-items:flex-start;justify-content:space-between;gap:1rem;list-style:none;cursor:pointer;padding:1.2rem 1.35rem;font-family:var(--display-font);font-size:1.2rem;line-height:1.08;letter-spacing:-0.02em;}"
    , ".faq-item summary::-webkit-details-marker{display:none;}"
    , ".faq-item summary::after{content:\"+\";flex:none;font-family:var(--mono-font);font-size:1rem;color:var(--accent);}"
    , ".faq-item[open] summary::after{content:\"-\";}"
    , ".faq-answer{margin:0;padding:0 1.35rem 1.35rem;color:var(--muted);}"
    , ".code-block{padding:0;overflow:hidden;background:linear-gradient(180deg,color-mix(in srgb,var(--text) 7%,#0b1220) 0%,color-mix(in srgb,var(--text) 10%,#0f172a) 100%);border-color:color-mix(in srgb,var(--accent) 18%,var(--border));box-shadow:0 20px 44px rgba(15,23,42,0.16);}"
    , ".code-meta{display:flex;flex-wrap:wrap;justify-content:space-between;gap:0.75rem;padding:1rem 1.2rem;border-bottom:1px solid rgba(255,255,255,0.08);background:rgba(255,255,255,0.06);}"
    , ".code-title,.code-language{color:#dbeafe;}"
    , ".code-language{color:color-mix(in srgb,var(--accent) 40%,white);}"
    , ".code-block pre{margin:0;padding:1.25rem 1.3rem 1.4rem;overflow:auto;font-family:var(--mono-font);font-size:0.92rem;line-height:1.6;color:#e2e8f0;}"
    , ".code-block code{display:block;white-space:pre;}"
    , ".image-block{padding:0;overflow:hidden;}"
    , ".image-block img{display:block;width:100%;height:auto;aspect-ratio:4 / 3;object-fit:cover;background:linear-gradient(135deg,color-mix(in srgb,var(--accent) 8%,var(--panel)) 0%,var(--panel) 100%);}"
    , ".image-caption{margin:0;padding:0.95rem 1.2rem;border-top:1px solid var(--border);color:var(--muted);}"
    , ".callout{border-left:0;padding-left:calc(var(--card-padding) + 0.2rem);position:relative;background:linear-gradient(180deg,color-mix(in srgb,var(--accent) 4%,white) 0%,color-mix(in srgb,var(--panel) 96%,white) 100%);}"
    , ".callout::before{content:\"\";position:absolute;left:0;top:1.1rem;bottom:1.1rem;width:4px;border-radius:999px;background:color-mix(in srgb,var(--border) 88%,white);}"
    , ".callout-accent::before{background:var(--accent);}"
    , ".callout-strong{background:linear-gradient(180deg,color-mix(in srgb,var(--text) 4%,white) 0%,color-mix(in srgb,var(--panel) 94%,white) 100%);}"
    , ".callout-strong::before{background:var(--text);}"
    , ".link-card{display:grid;gap:0.8rem;align-content:start;min-height:11rem;position:relative;overflow:hidden;}"
    , ".link-card::after{content:\"↗\";position:absolute;right:1.15rem;top:1.1rem;font-family:var(--mono-font);font-size:0.9rem;color:var(--accent);opacity:0.8;}"
    , ".link-card:hover{transform:translateY(-2px);box-shadow:0 22px 48px rgba(15,23,42,0.12);}"
    , ".hero-actions .link-card{min-height:auto;background:color-mix(in srgb,var(--panel) 78%,white);}"
    , ".hero-actions .link-card::after{content:\"→\";}"
    , ".link-card strong,.feature-card h3,.callout h3{font-family:var(--display-font);font-size:1.35rem;line-height:1.05;margin:0;letter-spacing:-0.02em;}"
    , ".site-footer{padding:0 0 1rem;color:var(--muted);}"
    , ".site-footer-inner{display:grid;gap:0.45rem;padding:1.15rem 1.35rem;border:1px solid color-mix(in srgb,var(--border) 82%,transparent);border-radius:calc(var(--radius) * 0.8);background:color-mix(in srgb,var(--panel) 88%,white);box-shadow:0 16px 40px rgba(15,23,42,0.08);}"
    , ".site-footer-title,.site-footer-description{margin:0;}"
    , ".site-footer-title{font-family:var(--display-font);font-size:1.05rem;color:var(--text);letter-spacing:-0.02em;}"
    , "html:lang(ja){--display-font:\"Noto Sans JP\",\"Hiragino Sans\",\"Yu Gothic UI\",\"Yu Gothic\",sans-serif;--body-font:\"Noto Sans JP\",\"Hiragino Sans\",\"Yu Gothic UI\",\"Yu Gothic\",sans-serif;}"
    , "html:lang(ja) body{line-height:1.78;}"
    , "html:lang(ja) .site-description{line-height:1.6;}"
    , "html:lang(ja) .site-nav-link,html:lang(ja) .locale-switch-link{font-family:var(--body-font);font-size:0.9rem;letter-spacing:0.02em;text-transform:none;}"
    , "html:lang(ja) .page-kind,html:lang(ja) .hero-eyebrow,html:lang(ja) .callout-tone,html:lang(ja) .link-card-meta,html:lang(ja) .metric-label,html:lang(ja) .timeline-meta,html:lang(ja) .person-role,html:lang(ja) .quote-attribution strong,html:lang(ja) .code-title,html:lang(ja) .code-language{font-family:var(--body-font);letter-spacing:0.04em;text-transform:none;}"
    , "html:lang(ja) .page-intro h1,html:lang(ja) .hero-block h1{font-size:clamp(2.35rem,4.9vw,4.7rem);line-height:1.1;max-width:11.2em;letter-spacing:-0.03em;}"
    , "html:lang(ja) .page-summary,html:lang(ja) .hero-body,html:lang(ja) .prose-block,html:lang(ja) .link-card-summary,html:lang(ja) .metric-detail,html:lang(ja) .faq-answer{line-height:1.82;}"
    , "html:lang(ja) .section-header h2,html:lang(ja) .link-card strong,html:lang(ja) .feature-card h3,html:lang(ja) .timeline-entry h3,html:lang(ja) .callout h3,html:lang(ja) .person-name,html:lang(ja) .faq-item summary{line-height:1.28;}"
    , "@media (max-width: 960px){"
    , ".content-section-composite .section-stack{grid-template-columns:1fr;}"
    , ".content-section-composite .hero-block{grid-row:auto;}"
    , ".content-section-composite .metric-grid{grid-template-columns:repeat(auto-fit,minmax(12rem,1fr));}"
    , "}"
    , "@media (max-width: 720px){"
    , ".page-shell{padding-top:0.5rem;}"
    , ".site-header{padding:0 0.75rem;}"
    , ".site-header-inner,.page-main,.site-footer{width:min(72rem,calc(100% - 1.5rem));}"
    , ".site-header-inner{align-items:flex-start;flex-direction:column;}"
    , ".site-header-actions{justify-content:flex-start;}"
    , ".site-nav{justify-content:flex-start;}"
    , ".site-description{max-width:none;}"
    , ".page-main{padding-top:2.2rem;}"
    , ".hero-block{padding:1.5rem;}"
    , ".hero-block h1{font-size:clamp(2.35rem,12vw,3.6rem);}"
    , ".page-intro h1{font-size:clamp(2.1rem,10vw,3.2rem);}"
    , ".content-section-code.content-section-composite .hero-block{order:1;}"
    , ".content-section-code.content-section-composite .code-block{order:2;grid-column:auto;}"
    , ".content-section-code.content-section-composite .feature-grid,.content-section-code.content-section-composite .metric-grid,.content-section-code.content-section-composite .timeline,.content-section-code.content-section-composite .callout{order:3;}"
    , ".hero-actions,.link-grid,.feature-grid,.metric-grid,.people-grid{grid-template-columns:1fr;}"
    , ".link-card{min-height:auto;}"
    , "}"
    ])

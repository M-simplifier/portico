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
        , content: renderStylesheet currentTheme
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
    , renderHeadStyles styleStrategy currentTheme
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
          , content: renderStylesheet currentTheme
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

renderHeadStyles :: StyleStrategy -> Theme -> String
renderHeadStyles styleStrategy currentTheme =
  case styleStrategy of
    InlineStyles ->
      "<style>" <> renderStylesheet currentTheme <> "</style>"
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
    [ "<a class=\"site-nav-link\" href=\""
    , escapeHtml (resolveTarget routeContext item.target)
    , "\">"
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
    , " class=\"content-section\">"
    , renderSectionHeader currentSection
    , "<div class=\"section-stack\">"
    , foldMap (renderBlock routeContext currentSite currentPage) currentSection.blocks
    , "</div>"
    , "</section>"
    ]

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
  joinWith ""
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
    , "*{box-sizing:border-box;}"
    , "html{scroll-behavior:smooth;}"
    , "body{margin:0;color:var(--text);font-family:var(--body-font);line-height:1.65;background:linear-gradient(180deg,var(--panel) 0%,var(--background) 14%,var(--background) 100%);}"
    , "a{color:inherit;text-decoration:none;}"
    , ".skip-link{position:absolute;left:1rem;top:-3rem;padding:0.75rem 1rem;background:var(--text);color:var(--panel);border-radius:var(--pill-radius);z-index:10;}"
    , ".skip-link:focus{top:1rem;}"
    , ".page-shell{min-height:100vh;}"
    , ".site-header{position:sticky;top:0;z-index:5;padding:var(--stack-gap) calc(var(--page-inset) / 2);background:var(--header-surface);backdrop-filter:blur(14px);border-bottom:1px solid var(--border);}"
    , ".site-header-inner,.page-main,.site-footer{width:min(var(--frame-width),calc(100% - var(--page-inset)));margin:0 auto;}"
    , ".site-header-inner{display:flex;align-items:center;justify-content:space-between;gap:1.5rem;}"
    , ".site-brand{display:flex;align-items:center;gap:1rem;min-width:0;}"
    , ".site-brand-mark{display:grid;place-items:center;width:2.5rem;height:2.5rem;border-radius:var(--brand-radius);background:var(--text);color:var(--panel);font-family:var(--mono-font);font-size:0.78rem;letter-spacing:0.14em;text-transform:uppercase;box-shadow:var(--shadow);}"
    , ".site-brand-copy strong{display:block;font-family:var(--display-font);font-size:1.05rem;font-weight:600;}"
    , ".site-description{margin:0.15rem 0 0;color:var(--muted);font-size:0.92rem;}"
    , ".site-header-actions{display:flex;flex-wrap:wrap;justify-content:flex-end;align-items:center;gap:0.75rem;}"
    , ".site-nav{display:flex;flex-wrap:wrap;justify-content:flex-end;gap:0.75rem;}"
    , ".site-nav-link{padding:0.6rem 0.95rem;border:1px solid color-mix(in srgb,var(--accent) 16%,var(--border));border-radius:var(--pill-radius);background:color-mix(in srgb,var(--accent) 4%,var(--panel));color:color-mix(in srgb,var(--text) 80%,var(--accent));font-weight:600;box-shadow:0 10px 30px color-mix(in srgb,var(--accent) 8%,transparent);}"
    , ".site-nav-link:hover{color:var(--text);border-color:var(--accent);background:color-mix(in srgb,var(--accent) 8%,var(--panel));}"
    , ".locale-switch{display:flex;flex-wrap:wrap;gap:0.45rem;}"
    , ".locale-switch-link{padding:0.45rem 0.8rem;border:1px solid var(--border);border-radius:var(--pill-radius);background:color-mix(in srgb,var(--panel) 88%,white);font-family:var(--mono-font);font-size:0.76rem;letter-spacing:0.08em;text-transform:uppercase;color:var(--muted);}"
    , ".locale-switch-link:hover{color:var(--text);border-color:var(--accent);}"
    , ".locale-switch-link-current{color:var(--text);border-color:var(--accent);background:color-mix(in srgb,var(--accent) 8%,var(--panel));}"
    , ".page-main{padding:var(--page-top) 0 var(--page-bottom);}"
    , ".page-intro{margin-bottom:2.5rem;}"
    , ".page-kind,.hero-eyebrow,.callout-tone,.link-card-meta{margin:0;letter-spacing:0.12em;text-transform:uppercase;font-size:0.78rem;font-family:var(--mono-font);color:var(--accent);}"
    , ".page-intro h1,.hero-block h1{margin:0.5rem 0 0;font-family:var(--display-font);font-size:clamp(2.8rem,6vw,5.4rem);line-height:0.98;max-width:12ch;}"
    , ".page-summary,.hero-body{max-width:42rem;font-size:1.08rem;color:var(--muted);}"
    , ".content-section + .content-section{margin-top:var(--section-gap);}"
    , ".section-header h2{margin:0 0 1rem;font-family:var(--display-font);font-size:1.6rem;}"
    , ".section-stack{display:grid;gap:var(--stack-gap);}"
    , ".block-card{border:1px solid var(--border);border-radius:var(--radius);background:var(--panel);box-shadow:var(--shadow);}"
    , ".hero-block{padding:var(--hero-padding);display:grid;gap:1rem;overflow:hidden;position:relative;background:var(--hero-surface);}"
    , ".hero-actions,.link-grid,.feature-grid,.metric-grid,.people-grid{display:grid;gap:1rem;grid-template-columns:repeat(auto-fit,minmax(15rem,1fr));}"
    , ".timeline,.faq-list{display:grid;gap:1rem;}"
    , ".prose-block,.feature-card,.metric-card,.timeline-entry,.person-card,.quote-block,.callout,.link-card{padding:var(--card-padding);}"
    , ".prose-block p,.feature-card p,.timeline-entry p,.callout p,.link-card-summary,.metric-detail,.quote-context,.person-detail{margin:0.65rem 0 0;color:var(--muted);}"
    , ".metric-value{margin:0;font-family:var(--display-font);font-size:clamp(2rem,5vw,3.4rem);line-height:0.95;}"
    , ".metric-label{margin:0.45rem 0 0;font-family:var(--mono-font);letter-spacing:0.12em;text-transform:uppercase;font-size:0.78rem;color:var(--accent);}"
    , ".timeline-entry{position:relative;overflow:hidden;}"
    , ".timeline-entry::before{content:\"\";position:absolute;left:0;top:0;bottom:0;width:5px;background:color-mix(in srgb,var(--accent) 60%,var(--panel));}"
    , ".timeline-entry h3{margin:0;font-family:var(--display-font);font-size:1.3rem;line-height:1.1;}"
    , ".timeline-meta{margin:0 0 0.65rem;padding-left:1rem;font-family:var(--mono-font);letter-spacing:0.12em;text-transform:uppercase;font-size:0.78rem;color:var(--accent);}"
    , ".person-card{display:grid;gap:0.7rem;align-content:start;}"
    , ".person-role{margin:0;font-family:var(--mono-font);letter-spacing:0.12em;text-transform:uppercase;font-size:0.78rem;color:var(--accent);}"
    , ".person-name{margin:0;font-family:var(--display-font);font-size:1.35rem;line-height:1.08;}"
    , ".person-bio{margin:0;color:var(--muted);}"
    , ".quote-block{display:grid;gap:1rem;background:var(--quote-surface);}"
    , ".quote-body{margin:0;}"
    , ".quote-body p{margin:0;font-family:var(--display-font);font-size:clamp(1.4rem,3vw,2.2rem);line-height:1.18;max-width:24ch;}"
    , ".quote-attribution{margin:0;padding-top:1rem;border-top:1px solid var(--border);}"
    , ".quote-attribution strong{display:block;font-family:var(--mono-font);letter-spacing:0.12em;text-transform:uppercase;font-size:0.78rem;color:var(--accent);}"
    , ".faq-item{padding:0;overflow:hidden;}"
    , ".faq-item[open]{background:color-mix(in srgb,var(--accent) 5%,var(--panel));}"
    , ".faq-item summary{display:flex;align-items:flex-start;justify-content:space-between;gap:1rem;list-style:none;cursor:pointer;padding:1.2rem 1.35rem;font-family:var(--display-font);font-size:1.2rem;line-height:1.15;}"
    , ".faq-item summary::-webkit-details-marker{display:none;}"
    , ".faq-item summary::after{content:\"+\";flex:none;font-family:var(--mono-font);font-size:1rem;color:var(--accent);}"
    , ".faq-item[open] summary::after{content:\"-\";}"
    , ".faq-answer{margin:0;padding:0 1.35rem 1.35rem;color:var(--muted);}"
    , ".code-block{padding:0;overflow:hidden;background:linear-gradient(180deg,color-mix(in srgb,var(--text) 2%,var(--panel)) 0%,var(--panel) 100%);}"
    , ".code-meta{display:flex;flex-wrap:wrap;justify-content:space-between;gap:0.75rem;padding:1rem 1.2rem;border-bottom:1px solid var(--border);background:color-mix(in srgb,var(--accent) 5%,var(--panel));}"
    , ".code-title,.code-language{font-family:var(--mono-font);letter-spacing:0.08em;text-transform:uppercase;font-size:0.76rem;}"
    , ".code-language{color:var(--accent);}"
    , ".code-block pre{margin:0;padding:1.2rem;overflow:auto;font-family:var(--mono-font);font-size:0.92rem;line-height:1.6;color:var(--text);}"
    , ".code-block code{display:block;white-space:pre;}"
    , ".image-block{padding:0;overflow:hidden;}"
    , ".image-block img{display:block;width:100%;height:auto;aspect-ratio:4 / 3;object-fit:cover;background:linear-gradient(135deg,color-mix(in srgb,var(--accent) 8%,var(--panel)) 0%,var(--panel) 100%);}"
    , ".image-caption{margin:0;padding:0.95rem 1.2rem;border-top:1px solid var(--border);color:var(--muted);}"
    , ".callout{border-left:6px solid var(--border);}"
    , ".callout-accent{border-left-color:var(--accent);}"
    , ".callout-strong{border-left-color:var(--text);background:color-mix(in srgb,var(--text) 5%,var(--panel));}"
    , ".link-card{display:grid;gap:0.75rem;align-content:start;min-height:11rem;}"
    , ".link-card strong,.feature-card h3,.timeline-entry h3,.callout h3{font-family:var(--display-font);font-size:1.3rem;line-height:1.1;margin:0;}"
    , ".site-footer{padding:0 0 var(--page-inset);color:var(--muted);}"
    , ".site-footer-inner{display:grid;gap:0.45rem;padding:1.15rem 1.35rem;border:1px solid var(--border);border-radius:calc(var(--radius) * 0.8);background:color-mix(in srgb,var(--accent) 4%,var(--panel));box-shadow:var(--shadow);}"
    , ".site-footer-title,.site-footer-description{margin:0;}"
    , ".site-footer-title{font-family:var(--display-font);font-size:1.05rem;color:var(--text);}"
    , "@media (max-width: 720px){"
    , ".site-header{padding:1rem;}"
    , ".site-header-inner,.page-main,.site-footer{width:min(72rem,calc(100% - 2rem));}"
    , ".site-header-inner{align-items:flex-start;flex-direction:column;}"
    , ".site-header-actions{justify-content:flex-start;}"
    , ".site-nav{justify-content:flex-start;}"
    , ".page-main{padding-top:2.5rem;}"
    , ".hero-block{padding:1.35rem;}"
    , "}"
    ]

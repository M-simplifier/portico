module Example.Official.PublicSite
  ( PublicBuildConfig
  , buildPublicSite
  , buildPublicSiteWithConfig
  , publicBuildConfig
  , publicOutputDirectory
  ) where

import Prelude

import Data.Array as Array
import Data.Foldable (foldMap, traverse_)
import Data.Maybe (Maybe(..))
import Example.Official.FileSystem (removeTree)
import Example.Official.LocalizedSite (officialLocalizedSite)
import Example.Official.Showcase (buildMountedShowcaseWithSiteTransform, mountedShowcasePaths, sampleSitesWithPaths, showcaseSiteWithPaths)
import Example.Official.Site (officialSite)
import Effect (Effect)
import Portico
  ( Block(..)
    , CalloutTone(..)
    , LocalizedSite
    , LocalizedVariant
    , Page
    , PageKind(..)
    , RenderedAsset
    , Site
    , callout
    , collectionLinkCard
    , emitLocalizedSite
    , emitRenderedAsset
    , emitRenderedPage
    , hero
    , localeCode
    , namedSection
    , officialTheme
    , page
    , pageKey
    , pagePath
    , renderPage
    , slugLinkCard
    , withActions
    , withBaseUrl
  , withEyebrow
  , withSummary
  )

type PublicBuildConfig =
  { baseUrl :: Maybe String
  }

publicOutputDirectory :: String
publicOutputDirectory = "site/dist"

publicBuildConfig :: PublicBuildConfig
publicBuildConfig =
  { baseUrl: maybeString publicBuildBaseUrl
  }

buildPublicSite :: String -> Effect Unit
buildPublicSite =
  buildPublicSiteWithConfig publicBuildConfig

buildPublicSiteWithConfig :: PublicBuildConfig -> String -> Effect Unit
buildPublicSiteWithConfig config outputDirectory = do
  removeTree outputDirectory
  emitLocalizedSite outputDirectory officialTheme (applyBuildConfigToLocalized config officialLocalizedSite)
  buildMountedShowcaseWithSiteTransform (applyBuildConfig config) outputDirectory "lab"
  emitRenderedPage outputDirectory (renderPage officialTheme (applyBuildConfig config officialSite) notFoundPage)
  traverse_ (emitRenderedAsset outputDirectory) (publishAssets config)

publishAssets :: PublicBuildConfig -> Array RenderedAsset
publishAssets config =
  robotsAsset config <> sitemapAsset config

robotsAsset :: PublicBuildConfig -> Array RenderedAsset
robotsAsset config =
  [ { path: "robots.txt"
    , content: robotsContent config
    }
  ]

sitemapAsset :: PublicBuildConfig -> Array RenderedAsset
sitemapAsset config =
  case config.baseUrl of
    Just _ ->
      [ { path: "sitemap.xml"
        , content: sitemapContent config
        }
      ]
    Nothing ->
      []

robotsContent :: PublicBuildConfig -> String
robotsContent config =
  case config.baseUrl of
    Just baseUrl ->
      joinLines
        [ "User-agent: *"
        , "Allow: /"
        , ""
        , "Sitemap: " <> absoluteUrl baseUrl "sitemap.xml"
        ]
    Nothing ->
      joinLines
        [ "User-agent: *"
        , "Allow: /"
        ]

sitemapContent :: PublicBuildConfig -> String
sitemapContent config =
  case config.baseUrl of
    Just baseUrl ->
      let
        entries = publicSitemapEntries baseUrl
      in
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
          <> "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\" xmlns:xhtml=\"http://www.w3.org/1999/xhtml\">\n"
          <> foldMap renderSitemapEntry entries
          <> "</urlset>\n"
    Nothing ->
      ""

type SitemapAlternate =
  { lang :: String
  , href :: String
  }

type SitemapEntry =
  { loc :: String
  , alternates :: Array SitemapAlternate
  }

publicSitemapEntries :: String -> Array SitemapEntry
publicSitemapEntries baseUrl =
  localizedSitemapEntries baseUrl officialLocalizedSite
    <> map (simpleSitemapEntry baseUrl) sharedCollectionPaths

sharedCollectionPaths :: Array String
sharedCollectionPaths =
  pagePathsAtMount "lab" (showcaseSiteWithPaths (mountedShowcasePaths "lab"))
    <> foldMap samplePagePaths (sampleSitesWithPaths (mountedShowcasePaths "lab"))

simpleSitemapEntry :: String -> String -> SitemapEntry
simpleSitemapEntry baseUrl urlPath =
  { loc: absoluteUrl baseUrl urlPath
  , alternates: []
  }

renderSitemapEntry :: SitemapEntry -> String
renderSitemapEntry entry =
  "  <url><loc>"
    <> escapeXml entry.loc
    <> "</loc>"
    <> foldMap renderSitemapAlternate entry.alternates
    <> "</url>\n"

renderSitemapAlternate :: SitemapAlternate -> String
renderSitemapAlternate alternate =
  "<xhtml:link rel=\"alternate\" hreflang=\""
    <> escapeXml alternate.lang
    <> "\" href=\""
    <> escapeXml alternate.href
    <> "\"/>"

localizedSitemapEntries :: String -> LocalizedSite -> Array SitemapEntry
localizedSitemapEntries baseUrl currentLocalizedSite =
  foldMap (localizedVariantEntries baseUrl currentLocalizedSite) currentLocalizedSite.variants

localizedVariantEntries :: String -> LocalizedSite -> LocalizedVariant -> Array SitemapEntry
localizedVariantEntries baseUrl currentLocalizedSite currentVariant =
  map
    (\currentPage ->
      let
        currentPath = mountedPath currentVariant.mountPath (pagePath currentPage)
      in
        { loc: absoluteUrl baseUrl currentPath
        , alternates: localizedAlternates baseUrl currentLocalizedSite currentPage
        })
    currentVariant.site.pages

localizedAlternates :: String -> LocalizedSite -> Page -> Array SitemapAlternate
localizedAlternates baseUrl currentLocalizedSite currentPage =
  foldMap
    (\currentVariant ->
      case localizedPagePath currentVariant currentPage of
        Just outputPath ->
          [ { lang: localeCode currentVariant.locale
            , href: absoluteUrl baseUrl outputPath
            }
          ]
        Nothing ->
          []
    )
    currentLocalizedSite.variants

localizedPagePath :: LocalizedVariant -> Page -> Maybe String
localizedPagePath currentVariant currentPage =
  case findPageByKey currentPage currentVariant.site of
    Just localizedPage ->
      Just (mountedPath currentVariant.mountPath (pagePath localizedPage))
    Nothing ->
      Nothing

samplePagePaths :: forall r. { slug :: String, site :: Site | r } -> Array String
samplePagePaths sampleSite =
  pagePathsAtMount ("samples/" <> sampleSite.slug) sampleSite.site

pagePathsAtMount :: String -> Site -> Array String
pagePathsAtMount mountPath currentSite =
  map (mountedPath mountPath <<< pagePath) currentSite.pages

findPageByKey :: Page -> Site -> Maybe Page
findPageByKey currentPage currentSite =
  Array.find (\candidatePage -> pageKey candidatePage == pageKey currentPage) currentSite.pages

applyBuildConfig :: PublicBuildConfig -> Site -> Site
applyBuildConfig config currentSite =
  case config.baseUrl of
    Just baseUrl -> withBaseUrl baseUrl currentSite
    Nothing -> currentSite

applyBuildConfigToLocalized :: PublicBuildConfig -> LocalizedSite -> LocalizedSite
applyBuildConfigToLocalized config currentLocalizedSite =
  currentLocalizedSite
    { variants =
        map
          (\currentVariant -> currentVariant { site = applyBuildConfig config currentVariant.site })
          currentLocalizedSite.variants
    }

notFoundPage :: Page
notFoundPage =
  withSummary
    "A fallback page for unknown routes on the public Portico site."
    (page
      "404"
      (CustomKind "Not found")
      "Page Not Found"
      [ namedSection
          "Missing route"
          [ HeroBlock
              (withActions
                [ slugLinkCard "Return to the official home" "index" (Just "Go back to the Portico front door.")
                , collectionLinkCard "Open the Japanese home" "ja/index.html" (Just "Switch to the Japanese official site entry.")
                , collectionLinkCard "Open the sample lab" "lab/index.html" (Just "Jump into the mounted chooser and sample surfaces.")
                ]
                (withEyebrow
                  "404"
                  (hero
                    "This route does not exist."
                    "The public Portico site now emits a dedicated 404 page so static hosting has an intentional fallback surface.")))
          , CalloutBlock
              (callout Quiet "Why it exists" "GitHub Pages and other static hosts should land on a real fallback page instead of exposing a server default.")
          ]
      ])

maybeString :: String -> Maybe String
maybeString value =
  if value == "" then
    Nothing
  else
    Just value

mountedPath :: String -> String -> String
mountedPath prefix path
  | prefix == "" = path
  | path == "" = prefix
  | otherwise = prefix <> "/" <> path

joinLines :: Array String -> String
joinLines =
  foldMap (_ <> "\n")

foreign import absoluteUrl :: String -> String -> String
foreign import escapeXml :: String -> String
foreign import publicBuildBaseUrl :: String

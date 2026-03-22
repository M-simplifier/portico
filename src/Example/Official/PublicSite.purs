module Example.Official.PublicSite
  ( PublicBuildConfig
  , buildPublicSite
  , buildPublicSiteWithConfig
  , publicBuildConfig
  , publicOutputDirectory
  ) where

import Prelude

import Data.Foldable (foldMap, traverse_)
import Data.Maybe (Maybe(..))
import Example.Official.FileSystem (removeTree)
import Example.Official.Showcase (buildMountedShowcaseWithSiteTransform, mountedShowcasePaths, sampleSitesWithPaths, showcaseSiteWithPaths)
import Example.Official.Site (officialSite)
import Effect (Effect)
import Portico
  ( Block(..)
  , CalloutTone(..)
  , Page
  , PageKind(..)
  , RenderedAsset
  , Site
  , callout
  , collectionLinkCard
  , emitRenderedAsset
  , emitRenderedPage
  , emitSite
  , hero
  , namedSection
  , officialTheme
  , page
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
  emitSite outputDirectory officialTheme (applyBuildConfig config officialSite)
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
        urls = map (absoluteUrl baseUrl) publicPagePaths
      in
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
          <> "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
          <> foldMap (\url -> "  <url><loc>" <> escapeXml url <> "</loc></url>\n") urls
          <> "</urlset>\n"
    Nothing ->
      ""

publicPagePaths :: Array String
publicPagePaths =
  pagePathsAtMount "" officialSite
    <> pagePathsAtMount "lab" (showcaseSiteWithPaths (mountedShowcasePaths "lab"))
    <> foldMap samplePagePaths (sampleSitesWithPaths (mountedShowcasePaths "lab"))

samplePagePaths :: forall r. { slug :: String, site :: Site | r } -> Array String
samplePagePaths sampleSite =
  pagePathsAtMount ("samples/" <> sampleSite.slug) sampleSite.site

pagePathsAtMount :: String -> Site -> Array String
pagePathsAtMount mountPath currentSite =
  map (mountedPath mountPath <<< pagePath) currentSite.pages

applyBuildConfig :: PublicBuildConfig -> Site -> Site
applyBuildConfig config currentSite =
  case config.baseUrl of
    Just baseUrl -> withBaseUrl baseUrl currentSite
    Nothing -> currentSite

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

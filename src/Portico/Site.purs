module Portico.Site
  ( Site
  , LinkTarget(..)
  , AssetTarget(..)
  , NavItem
  , Page
  , PageKind(..)
  , Section
  , Block(..)
  , Hero
  , Feature
  , Metric
  , TimelineEntry
  , CodeSample
  , Image
  , Person
  , Quote
  , FaqEntry
  , Callout
  , CalloutTone(..)
  , LinkCard
  , site
  , withBaseUrl
  , withDescription
  , withDefaultSocialImage
  , withNavigation
  , navItem
  , siteNavItem
  , collectionNavItem
  , slugNavItem
  , pageNavItem
  , page
  , slugPath
  , pagePath
  , withSocialImage
  , withSummary
  , section
  , namedSection
  , withSectionId
  , hero
  , withEyebrow
  , withActions
  , feature
  , metric
  , timelineEntry
  , codeSample
  , image
  , siteImage
  , collectionImage
  , withCaption
  , person
  , quote
  , faqEntry
  , callout
  , linkCard
  , siteLinkCard
  , collectionLinkCard
  , slugLinkCard
  , pageLinkCard
  ) where

import Prelude

import Data.Maybe (Maybe(..))

type Site =
  { title :: String
  , description :: Maybe String
  , baseUrl :: Maybe String
  , socialImage :: Maybe AssetTarget
  , navigation :: Array NavItem
  , pages :: Array Page
  }

data LinkTarget
  = ExternalHref String
  | SitePath String
  | CollectionPath String

data AssetTarget
  = ExternalAsset String
  | SiteAsset String
  | CollectionAsset String

type NavItem =
  { label :: String
  , target :: LinkTarget
  }

data PageKind
  = Landing
  | Documentation
  | Article
  | ReleaseNotes
  | Showcase
  | Microsite
  | Profile
  | CustomKind String

type Page =
  { slug :: String
  , kind :: PageKind
  , title :: String
  , summary :: Maybe String
  , socialImage :: Maybe AssetTarget
  , sections :: Array Section
  }

type Section =
  { id :: Maybe String
  , label :: Maybe String
  , blocks :: Array Block
  }

type Hero =
  { eyebrow :: Maybe String
  , title :: String
  , body :: String
  , actions :: Array LinkCard
  }

type Feature =
  { title :: String
  , body :: String
  }

type Metric =
  { label :: String
  , value :: String
  , detail :: Maybe String
  }

type TimelineEntry =
  { title :: String
  , body :: String
  , meta :: Maybe String
  }

type CodeSample =
  { code :: String
  , language :: Maybe String
  , title :: Maybe String
  }

type Image =
  { alt :: String
  , source :: AssetTarget
  , caption :: Maybe String
  }

type Person =
  { name :: String
  , role :: String
  , bio :: String
  , detail :: Maybe String
  }

type Quote =
  { body :: String
  , attribution :: String
  , context :: Maybe String
  }

type FaqEntry =
  { question :: String
  , answer :: String
  }

data CalloutTone
  = Quiet
  | Accent
  | Strong

type Callout =
  { tone :: CalloutTone
  , title :: String
  , body :: String
  }

type LinkCard =
  { label :: String
  , target :: LinkTarget
  , summary :: Maybe String
  }

data Block
  = HeroBlock Hero
  | ProseBlock String
  | FeatureGridBlock (Array Feature)
  | MetricsBlock (Array Metric)
  | TimelineBlock (Array TimelineEntry)
  | CodeBlock CodeSample
  | ImageBlock Image
  | PeopleBlock (Array Person)
  | QuoteBlock Quote
  | FaqBlock (Array FaqEntry)
  | CalloutBlock Callout
  | LinkGridBlock (Array LinkCard)

site :: String -> Array Page -> Site
site title pages =
  { title
  , description: Nothing
  , baseUrl: Nothing
  , socialImage: Nothing
  , navigation: []
  , pages
  }

withBaseUrl :: String -> Site -> Site
withBaseUrl baseUrl current =
  current { baseUrl = Just baseUrl }

withDescription :: String -> Site -> Site
withDescription description current =
  current { description = Just description }

withDefaultSocialImage :: AssetTarget -> Site -> Site
withDefaultSocialImage socialImage current =
  current { socialImage = Just socialImage }

withNavigation :: Array NavItem -> Site -> Site
withNavigation navigation current =
  current { navigation = navigation }

navItem :: String -> String -> NavItem
navItem label href =
  { label
  , target: ExternalHref href
  }

siteNavItem :: String -> String -> NavItem
siteNavItem label path =
  { label
  , target: SitePath path
  }

collectionNavItem :: String -> String -> NavItem
collectionNavItem label path =
  { label
  , target: CollectionPath path
  }

pageNavItem :: String -> Page -> NavItem
pageNavItem label currentPage =
  siteNavItem label (pagePath currentPage)

page :: String -> PageKind -> String -> Array Section -> Page
page slug kind title sections =
  { slug
  , kind
  , title
  , summary: Nothing
  , socialImage: Nothing
  , sections
  }

slugPath :: String -> String
slugPath slug =
  case slug of
    "" -> "index.html"
    "index" -> "index.html"
    currentSlug -> currentSlug <> ".html"

pagePath :: Page -> String
pagePath currentPage = slugPath currentPage.slug

slugNavItem :: String -> String -> NavItem
slugNavItem label slug =
  siteNavItem label (slugPath slug)

withSummary :: String -> Page -> Page
withSummary summary current =
  current { summary = Just summary }

withSocialImage :: AssetTarget -> Page -> Page
withSocialImage socialImage current =
  current { socialImage = Just socialImage }

section :: Array Block -> Section
section blocks =
  { id: Nothing
  , label: Nothing
  , blocks
  }

namedSection :: String -> Array Block -> Section
namedSection label blocks =
  { id: Nothing
  , label: Just label
  , blocks
  }

withSectionId :: String -> Section -> Section
withSectionId id current =
  current { id = Just id }

hero :: String -> String -> Hero
hero title body =
  { eyebrow: Nothing
  , title
  , body
  , actions: []
  }

withEyebrow :: String -> Hero -> Hero
withEyebrow eyebrow current =
  current { eyebrow = Just eyebrow }

withActions :: Array LinkCard -> Hero -> Hero
withActions actions current =
  current { actions = actions }

feature :: String -> String -> Feature
feature title body =
  { title, body }

metric :: String -> String -> Maybe String -> Metric
metric value label detail =
  { label
  , value
  , detail
  }

timelineEntry :: String -> String -> Maybe String -> TimelineEntry
timelineEntry title body meta =
  { title
  , body
  , meta
  }

codeSample :: String -> Maybe String -> Maybe String -> CodeSample
codeSample code language title =
  { code
  , language
  , title
  }

image :: String -> String -> Image
image alt src =
  { alt
  , source: ExternalAsset src
  , caption: Nothing
  }

siteImage :: String -> String -> Image
siteImage alt src =
  { alt
  , source: SiteAsset src
  , caption: Nothing
  }

collectionImage :: String -> String -> Image
collectionImage alt src =
  { alt
  , source: CollectionAsset src
  , caption: Nothing
  }

withCaption :: String -> Image -> Image
withCaption caption current =
  current { caption = Just caption }

person :: String -> String -> String -> Maybe String -> Person
person name role bio detail =
  { name
  , role
  , bio
  , detail
  }

quote :: String -> String -> Maybe String -> Quote
quote body attribution context =
  { body
  , attribution
  , context
  }

faqEntry :: String -> String -> FaqEntry
faqEntry question answer =
  { question
  , answer
  }

callout :: CalloutTone -> String -> String -> Callout
callout tone title body =
  { tone, title, body }

linkCard :: String -> String -> Maybe String -> LinkCard
linkCard label href summary =
  { label
  , target: ExternalHref href
  , summary
  }

siteLinkCard :: String -> String -> Maybe String -> LinkCard
siteLinkCard label path summary =
  { label
  , target: SitePath path
  , summary
  }

collectionLinkCard :: String -> String -> Maybe String -> LinkCard
collectionLinkCard label path summary =
  { label
  , target: CollectionPath path
  , summary
  }

slugLinkCard :: String -> String -> Maybe String -> LinkCard
slugLinkCard label slug summary =
  siteLinkCard label (slugPath slug) summary

pageLinkCard :: String -> Page -> Maybe String -> LinkCard
pageLinkCard label currentPage summary =
  siteLinkCard label (pagePath currentPage) summary

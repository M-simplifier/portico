module Portico.Validate
  ( ValidationCode(..)
  , ValidationDiagnostic
  , ValidationReport
  , ValidationSeverity(..)
  , hasErrors
  , hasLocalizedErrors
  , localizedSiteDiagnostics
  , localizedSiteErrors
  , localizedSiteWarnings
  , siteDiagnostics
  , siteErrors
  , siteWarnings
  , validateLocalizedSite
  , validateSite
  ) where

import Prelude

import Data.Array as Array
import Data.Foldable (foldMap)
import Data.Maybe (Maybe(..))
import Portico.Site (Block(..), LinkCard, LinkTarget(..), LocalizedSite, LocalizedVariant, NavItem, Page, Section, Site, localeCode, pageKey, pagePath)

data ValidationSeverity
  = ValidationError
  | ValidationWarning

derive instance eqValidationSeverity :: Eq ValidationSeverity

data ValidationCode
  = EmptySiteTitle
  | EmptySite
  | MissingSiteDescription
  | MissingIndexPage
  | DuplicatePagePath
  | DuplicatePageKey
  | EmptyNavigationLabel
  | EmptyPageTitle
  | MissingPageSummary
  | EmptyPageSections
  | EmptySection
  | DuplicateSectionId
  | BrokenSiteNavigation
  | EmptyLinkLabel
  | BrokenInternalLink
  | NonLeadingHero
  | DuplicateLocaleVariant
  | MissingDefaultLocaleVariant
  | SiteLocaleMismatch
  | MissingLocalizedPage

derive instance eqValidationCode :: Eq ValidationCode

type ValidationDiagnostic =
  { severity :: ValidationSeverity
  , code :: ValidationCode
  , message :: String
  , locale :: Maybe String
  , pagePath :: Maybe String
  , sectionId :: Maybe String
  }

type ValidationReport =
  { diagnostics :: Array ValidationDiagnostic
  }

type SiteValidator = Site -> Array ValidationDiagnostic
type LocalizedSiteValidator = LocalizedSite -> Array ValidationDiagnostic

validateSite :: Site -> ValidationReport
validateSite currentSite =
  { diagnostics: foldMap (\validator -> validator currentSite) siteValidators }

validateLocalizedSite :: LocalizedSite -> ValidationReport
validateLocalizedSite currentLocalizedSite =
  { diagnostics: foldMap (\validator -> validator currentLocalizedSite) localizedSiteValidators }

siteDiagnostics :: Site -> Array ValidationDiagnostic
siteDiagnostics = _.diagnostics <<< validateSite

localizedSiteDiagnostics :: LocalizedSite -> Array ValidationDiagnostic
localizedSiteDiagnostics = _.diagnostics <<< validateLocalizedSite

siteErrors :: Site -> Array ValidationDiagnostic
siteErrors currentSite =
  Array.filter (\diagnostic -> diagnostic.severity == ValidationError) (siteDiagnostics currentSite)

siteWarnings :: Site -> Array ValidationDiagnostic
siteWarnings currentSite =
  Array.filter (\diagnostic -> diagnostic.severity == ValidationWarning) (siteDiagnostics currentSite)

localizedSiteErrors :: LocalizedSite -> Array ValidationDiagnostic
localizedSiteErrors currentLocalizedSite =
  Array.filter (\diagnostic -> diagnostic.severity == ValidationError) (localizedSiteDiagnostics currentLocalizedSite)

localizedSiteWarnings :: LocalizedSite -> Array ValidationDiagnostic
localizedSiteWarnings currentLocalizedSite =
  Array.filter (\diagnostic -> diagnostic.severity == ValidationWarning) (localizedSiteDiagnostics currentLocalizedSite)

hasErrors :: Site -> Boolean
hasErrors =
  not <<< Array.null <<< siteErrors

hasLocalizedErrors :: LocalizedSite -> Boolean
hasLocalizedErrors =
  not <<< Array.null <<< localizedSiteErrors

siteValidators :: Array SiteValidator
siteValidators =
  [ validateSiteMetadata
  , validatePageInventory
  , validateSiteNavigation
  , validatePages
  ]

validateSiteMetadata :: SiteValidator
validateSiteMetadata currentSite =
  emptySiteTitleDiagnostic <> missingSiteDescriptionDiagnostic
  where
  emptySiteTitleDiagnostic =
    if currentSite.title == "" then
      [ siteDiagnostic ValidationError EmptySiteTitle "Site title should not be empty." ]
    else
      []

  missingSiteDescriptionDiagnostic =
    case currentSite.description of
      Nothing ->
        [ siteDiagnostic ValidationWarning MissingSiteDescription "Site description is missing. Public-facing sites should usually emit a site-level description." ]
      Just _ ->
        []

validatePageInventory :: SiteValidator
validatePageInventory currentSite =
  emptySiteDiagnostic <> missingIndexPageDiagnostic <> duplicatePagePathDiagnostics <> duplicatePageKeyDiagnostics
  where
  emptySiteDiagnostic =
    if Array.null currentSite.pages then
      [ siteDiagnostic ValidationError EmptySite "A site should contain at least one page." ]
    else
      []

  missingIndexPageDiagnostic =
    if Array.any (\currentPage -> pagePath currentPage == "index.html") currentSite.pages then
      []
    else
      [ siteDiagnostic ValidationError MissingIndexPage "A site should expose an index page at index.html." ]

  duplicatePagePathDiagnostics =
    map
      (\duplicatePath ->
        siteDiagnostic ValidationError DuplicatePagePath ("Multiple pages resolve to the same output path: " <> duplicatePath <> "."))
      (findDuplicateStrings (map pagePath currentSite.pages))

  duplicatePageKeyDiagnostics =
    map
      (\duplicateKey ->
        siteDiagnostic ValidationError DuplicatePageKey ("Multiple pages share the same localized page key: " <> duplicateKey <> "."))
      (findDuplicateStrings (map pageKey currentSite.pages))

validateSiteNavigation :: SiteValidator
validateSiteNavigation currentSite =
  foldMap (validateNavItem currentSite) currentSite.navigation

validateNavItem :: Site -> NavItem -> Array ValidationDiagnostic
validateNavItem currentSite currentItem =
  emptyLabelDiagnostic <> brokenTargetDiagnostic
  where
  emptyLabelDiagnostic =
    if currentItem.label == "" then
      [ siteDiagnostic ValidationError EmptyNavigationLabel "Navigation item label should not be empty." ]
    else
      []

  brokenTargetDiagnostic =
    case currentItem.target of
      SitePath targetPath ->
        if sitePathExists targetPath currentSite then
          []
        else
          [ siteDiagnostic ValidationError BrokenSiteNavigation ("Navigation item \"" <> currentItem.label <> "\" points to a missing site path: " <> targetPath <> ".") ]
      _ ->
        []

validatePages :: SiteValidator
validatePages currentSite =
  foldMap (validatePage currentSite) currentSite.pages

validatePage :: Site -> Page -> Array ValidationDiagnostic
validatePage currentSite currentPage =
  emptyTitleDiagnostic
    <> missingSummaryDiagnostic
    <> emptySectionsDiagnostic
    <> emptySectionDiagnostics
    <> duplicateSectionIdDiagnostics
    <> heroPlacementDiagnostics
    <> linkDiagnostics
  where
  currentPagePath = pagePath currentPage

  emptyTitleDiagnostic =
    if currentPage.title == "" then
      [ pageDiagnostic ValidationError EmptyPageTitle currentPagePath Nothing "Page title should not be empty." ]
    else
      []

  missingSummaryDiagnostic =
    case currentPage.summary of
      Nothing ->
        [ pageDiagnostic ValidationWarning MissingPageSummary currentPagePath Nothing "Page summary is missing. Public-facing pages should usually emit a summary for intro and metadata." ]
      Just _ ->
        []

  emptySectionsDiagnostic =
    if Array.null currentPage.sections then
      [ pageDiagnostic ValidationWarning EmptyPageSections currentPagePath Nothing "Page has no sections. Add at least one section so the page can render meaningful content." ]
    else
      []

  emptySectionDiagnostics =
    foldMap
      (\currentSection ->
        if Array.null currentSection.blocks then
          [ pageDiagnostic ValidationWarning EmptySection currentPagePath currentSection.id "Section has no blocks. Remove it or add content." ]
        else
          [])
      currentPage.sections

  duplicateSectionIdDiagnostics =
    map
      (\duplicateId ->
        pageDiagnostic ValidationError DuplicateSectionId currentPagePath (Just duplicateId) ("Section id \"" <> duplicateId <> "\" is duplicated within the page."))
      (findDuplicateStrings (foldMap sectionIdArray currentPage.sections))

  heroPlacementDiagnostics =
    if hasNonLeadingHero currentPage then
      [ pageDiagnostic ValidationWarning NonLeadingHero currentPagePath Nothing "Hero blocks should appear as the first block of the first section if they are used at all." ]
    else
      []

  linkDiagnostics =
    foldMap (validateSectionLinks currentSite currentPagePath) currentPage.sections

sectionIdArray :: Section -> Array String
sectionIdArray currentSection =
  case currentSection.id of
    Just sectionId -> [ sectionId ]
    Nothing -> []

validateSectionLinks :: Site -> String -> Section -> Array ValidationDiagnostic
validateSectionLinks currentSite currentPagePath currentSection =
  foldMap (validateBlockLinks currentSite currentPagePath currentSection.id) currentSection.blocks

validateBlockLinks :: Site -> String -> Maybe String -> Block -> Array ValidationDiagnostic
validateBlockLinks currentSite currentPagePath currentSectionId = case _ of
  HeroBlock currentHero ->
    foldMap (validateLinkCard currentSite currentPagePath currentSectionId "hero action") currentHero.actions
  LinkGridBlock currentCards ->
    foldMap (validateLinkCard currentSite currentPagePath currentSectionId "link grid card") currentCards
  _ ->
    []

validateLinkCard :: Site -> String -> Maybe String -> String -> LinkCard -> Array ValidationDiagnostic
validateLinkCard currentSite currentPagePath currentSectionId context currentCard =
  emptyLabelDiagnostic <> brokenTargetDiagnostic
  where
  emptyLabelDiagnostic =
    if currentCard.label == "" then
      [ pageDiagnostic ValidationError EmptyLinkLabel currentPagePath currentSectionId ("The " <> context <> " label should not be empty.") ]
    else
      []

  brokenTargetDiagnostic =
    case currentCard.target of
      SitePath targetPath ->
        if sitePathExists targetPath currentSite then
          []
        else
          [ pageDiagnostic ValidationError BrokenInternalLink currentPagePath currentSectionId ("The " <> context <> " \"" <> currentCard.label <> "\" points to a missing site path: " <> targetPath <> ".") ]
      _ ->
        []

sitePathExists :: String -> Site -> Boolean
sitePathExists targetPath currentSite =
  Array.any (\currentPage -> pagePath currentPage == targetPath) currentSite.pages

localizedSiteValidators :: Array LocalizedSiteValidator
localizedSiteValidators =
  [ validateLocalizedInventory
  , validateLocalizedVariants
  , validateLocalizedPageCoverage
  ]

validateLocalizedInventory :: LocalizedSiteValidator
validateLocalizedInventory currentLocalizedSite =
  duplicateLocaleDiagnostics <> missingDefaultLocaleDiagnostic
  where
  localeCodes =
    map (localeCode <<< _.locale) currentLocalizedSite.variants

  duplicateLocaleDiagnostics =
    map
      (\duplicateCode ->
        localizedDiagnostic ValidationError DuplicateLocaleVariant ("Localized site defines the locale \"" <> duplicateCode <> "\" more than once."))
      (findDuplicateStrings localeCodes)

  missingDefaultLocaleDiagnostic =
    if Array.any (\currentVariant -> currentVariant.locale == currentLocalizedSite.defaultLocale) currentLocalizedSite.variants then
      []
    else
      [ localizedDiagnostic ValidationError MissingDefaultLocaleVariant ("Localized site is missing its default locale variant: " <> localeCode currentLocalizedSite.defaultLocale <> ".") ]

validateLocalizedVariants :: LocalizedSiteValidator
validateLocalizedVariants currentLocalizedSite =
  foldMap validateLocalizedVariant currentLocalizedSite.variants

validateLocalizedVariant :: LocalizedVariant -> Array ValidationDiagnostic
validateLocalizedVariant currentVariant =
  map (withDiagnosticLocale currentVariant) (siteDiagnostics currentVariant.site)
    <> siteLocaleMismatchDiagnostic
  where
  siteLocaleMismatchDiagnostic =
    case currentVariant.site.locale of
      Just siteLocale | siteLocale == currentVariant.locale ->
        []
      _ ->
        [ localizedDiagnosticFor currentVariant ValidationError SiteLocaleMismatch ("Localized variant \"" <> localeCode currentVariant.locale <> "\" must carry the same site locale metadata.") ]

validateLocalizedPageCoverage :: LocalizedSiteValidator
validateLocalizedPageCoverage currentLocalizedSite =
  let
    pageKeys =
      uniqueStrings (foldMap (\currentVariant -> map pageKey currentVariant.site.pages) currentLocalizedSite.variants)
  in
    foldMap (missingLocalizedPageDiagnostics pageKeys) currentLocalizedSite.variants

missingLocalizedPageDiagnostics :: Array String -> LocalizedVariant -> Array ValidationDiagnostic
missingLocalizedPageDiagnostics pageKeys currentVariant =
  foldMap
    (\currentPageKey ->
      if localizedVariantHasPageKey currentPageKey currentVariant then
        []
      else
        [ localizedDiagnosticFor currentVariant ValidationWarning MissingLocalizedPage ("Localized variant \"" <> localeCode currentVariant.locale <> "\" is missing a page for localized page key \"" <> currentPageKey <> "\".") ]
    )
    pageKeys

localizedVariantHasPageKey :: String -> LocalizedVariant -> Boolean
localizedVariantHasPageKey currentPageKey currentVariant =
  Array.any (\currentPage -> pageKey currentPage == currentPageKey) currentVariant.site.pages

findDuplicateStrings :: Array String -> Array String
findDuplicateStrings =
  go [] []
  where
  go seen duplicates remaining =
    case Array.uncons remaining of
      Nothing ->
        duplicates
      Just { head, tail } ->
        if arrayContains head seen then
          if arrayContains head duplicates then
            go seen duplicates tail
          else
            go seen (duplicates <> [ head ]) tail
        else
          go (seen <> [ head ]) duplicates tail

arrayContains :: String -> Array String -> Boolean
arrayContains currentValue =
  Array.any (_ == currentValue)

uniqueStrings :: Array String -> Array String
uniqueStrings =
  go []
  where
  go uniqueValues remaining =
    case Array.uncons remaining of
      Nothing ->
        uniqueValues
      Just { head, tail } ->
        if arrayContains head uniqueValues then
          go uniqueValues tail
        else
          go (uniqueValues <> [ head ]) tail

hasNonLeadingHero :: Page -> Boolean
hasNonLeadingHero currentPage =
  goSections 0 currentPage.sections
  where
  goSections sectionIndex sections =
    case Array.uncons sections of
      Nothing ->
        false
      Just { head, tail } ->
        if goBlocks sectionIndex 0 head.blocks then
          true
        else
          goSections (sectionIndex + 1) tail

  goBlocks sectionIndex blockIndex blocks =
    case Array.uncons blocks of
      Nothing ->
        false
      Just { head, tail } ->
        case head of
          HeroBlock _ ->
            if sectionIndex == 0 && blockIndex == 0 then
              goBlocks sectionIndex (blockIndex + 1) tail
            else
              true
          _ ->
            goBlocks sectionIndex (blockIndex + 1) tail

siteDiagnostic :: ValidationSeverity -> ValidationCode -> String -> ValidationDiagnostic
siteDiagnostic severity code message =
  siteDiagnosticWithLocale Nothing severity code message

siteDiagnosticWithLocale :: Maybe String -> ValidationSeverity -> ValidationCode -> String -> ValidationDiagnostic
siteDiagnosticWithLocale currentLocale severity code message =
  { severity
  , code
  , message
  , locale: currentLocale
  , pagePath: Nothing
  , sectionId: Nothing
  }

pageDiagnostic :: ValidationSeverity -> ValidationCode -> String -> Maybe String -> String -> ValidationDiagnostic
pageDiagnostic severity code currentPagePath currentSectionId message =
  pageDiagnosticWithLocale Nothing severity code currentPagePath currentSectionId message

pageDiagnosticWithLocale :: Maybe String -> ValidationSeverity -> ValidationCode -> String -> Maybe String -> String -> ValidationDiagnostic
pageDiagnosticWithLocale currentLocale severity code currentPagePath currentSectionId message =
  { severity
  , code
  , message
  , locale: currentLocale
  , pagePath: Just currentPagePath
  , sectionId: currentSectionId
  }

localizedDiagnostic :: ValidationSeverity -> ValidationCode -> String -> ValidationDiagnostic
localizedDiagnostic =
  siteDiagnosticWithLocale Nothing

localizedDiagnosticFor :: LocalizedVariant -> ValidationSeverity -> ValidationCode -> String -> ValidationDiagnostic
localizedDiagnosticFor currentVariant severity code message =
  siteDiagnosticWithLocale (Just (localeCode currentVariant.locale)) severity code message

withDiagnosticLocale :: LocalizedVariant -> ValidationDiagnostic -> ValidationDiagnostic
withDiagnosticLocale currentVariant diagnostic =
  diagnostic { locale = Just (localeCode currentVariant.locale) }

module Portico.Validate
  ( ValidationCode(..)
  , ValidationDiagnostic
  , ValidationReport
  , ValidationSeverity(..)
  , hasErrors
  , siteDiagnostics
  , siteErrors
  , siteWarnings
  , validateSite
  ) where

import Prelude

import Data.Array as Array
import Data.Foldable (foldMap)
import Data.Maybe (Maybe(..))
import Portico.Site (Block(..), LinkCard, LinkTarget(..), NavItem, Page, Section, Site, pagePath)

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

derive instance eqValidationCode :: Eq ValidationCode

type ValidationDiagnostic =
  { severity :: ValidationSeverity
  , code :: ValidationCode
  , message :: String
  , pagePath :: Maybe String
  , sectionId :: Maybe String
  }

type ValidationReport =
  { diagnostics :: Array ValidationDiagnostic
  }

type SiteValidator = Site -> Array ValidationDiagnostic

validateSite :: Site -> ValidationReport
validateSite currentSite =
  { diagnostics: foldMap (\validator -> validator currentSite) siteValidators }

siteDiagnostics :: Site -> Array ValidationDiagnostic
siteDiagnostics = _.diagnostics <<< validateSite

siteErrors :: Site -> Array ValidationDiagnostic
siteErrors currentSite =
  Array.filter (\diagnostic -> diagnostic.severity == ValidationError) (siteDiagnostics currentSite)

siteWarnings :: Site -> Array ValidationDiagnostic
siteWarnings currentSite =
  Array.filter (\diagnostic -> diagnostic.severity == ValidationWarning) (siteDiagnostics currentSite)

hasErrors :: Site -> Boolean
hasErrors =
  not <<< Array.null <<< siteErrors

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
  emptySiteDiagnostic <> missingIndexPageDiagnostic <> duplicatePagePathDiagnostics
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
  { severity
  , code
  , message
  , pagePath: Nothing
  , sectionId: Nothing
  }

pageDiagnostic :: ValidationSeverity -> ValidationCode -> String -> Maybe String -> String -> ValidationDiagnostic
pageDiagnostic severity code currentPagePath currentSectionId message =
  { severity
  , code
  , message
  , pagePath: Just currentPagePath
  , sectionId: currentSectionId
  }

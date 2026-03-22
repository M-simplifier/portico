module Portico.Build
  ( defaultStylesheetPath
  , emitRenderedAsset
  , emitRenderedPage
  , emitRenderedSite
  , emitLocalizedSite
  , emitMountedLocalizedSite
  , emitMountedSite
  , emitSite
  ) where

import Prelude

import Data.Foldable (traverse_)
import Effect (Effect)
import Portico.Render (RenderedAsset, RenderedPage, RenderedSite, renderLocalizedSite, renderMountedLocalizedSite, renderMountedSite, renderStaticSite)
import Portico.Site (LocalizedSite, Site)
import Portico.Theme (Theme)

defaultStylesheetPath :: String
defaultStylesheetPath = "assets/portico.css"

emitSite :: String -> Theme -> Site -> Effect Unit
emitSite outputDirectory currentTheme currentSite =
  emitRenderedSite outputDirectory (renderStaticSite defaultStylesheetPath currentTheme currentSite)

emitLocalizedSite :: String -> Theme -> LocalizedSite -> Effect Unit
emitLocalizedSite outputDirectory currentTheme currentLocalizedSite =
  emitRenderedSite outputDirectory (renderLocalizedSite defaultStylesheetPath currentTheme currentLocalizedSite)

emitMountedSite :: String -> String -> Theme -> Site -> Effect Unit
emitMountedSite outputDirectory mountPath currentTheme currentSite =
  emitRenderedSite outputDirectory (renderMountedSite mountPath defaultStylesheetPath currentTheme currentSite)

emitMountedLocalizedSite :: String -> String -> Theme -> LocalizedSite -> Effect Unit
emitMountedLocalizedSite outputDirectory mountPath currentTheme currentLocalizedSite =
  emitRenderedSite outputDirectory (renderMountedLocalizedSite mountPath defaultStylesheetPath currentTheme currentLocalizedSite)

emitRenderedSite :: String -> RenderedSite -> Effect Unit
emitRenderedSite outputDirectory renderedSite = do
  traverse_ (emitRenderedAsset outputDirectory) renderedSite.assets
  traverse_ (emitRenderedPage outputDirectory) renderedSite.pages

emitRenderedAsset :: String -> RenderedAsset -> Effect Unit
emitRenderedAsset outputDirectory renderedAsset = do
  let
    outputPath = joinPath outputDirectory renderedAsset.path
  ensureDirectory (dirname outputPath)
  writeTextFile outputPath renderedAsset.content

emitRenderedPage :: String -> RenderedPage -> Effect Unit
emitRenderedPage outputDirectory renderedPage = do
  let
    outputPath = joinPath outputDirectory renderedPage.path
  ensureDirectory (dirname outputPath)
  writeTextFile outputPath renderedPage.html

foreign import dirname :: String -> String
foreign import ensureDirectory :: String -> Effect Unit
foreign import joinPath :: String -> String -> String
foreign import writeTextFile :: String -> String -> Effect Unit

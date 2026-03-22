module Portico.Build
  ( defaultStylesheetPath
  , emitRenderedAsset
  , emitRenderedPage
  , emitRenderedSite
  , emitMountedSite
  , emitSite
  ) where

import Prelude

import Data.Foldable (traverse_)
import Effect (Effect)
import Portico.Render (RenderedAsset, RenderedPage, RenderedSite, renderMountedSite, renderStaticSite)
import Portico.Site (Site)
import Portico.Theme (Theme)

defaultStylesheetPath :: String
defaultStylesheetPath = "assets/portico.css"

emitSite :: String -> Theme -> Site -> Effect Unit
emitSite outputDirectory currentTheme currentSite =
  emitRenderedSite outputDirectory (renderStaticSite defaultStylesheetPath currentTheme currentSite)

emitMountedSite :: String -> String -> Theme -> Site -> Effect Unit
emitMountedSite outputDirectory mountPath currentTheme currentSite =
  emitRenderedSite outputDirectory (renderMountedSite mountPath defaultStylesheetPath currentTheme currentSite)

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

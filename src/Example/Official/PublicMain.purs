module Example.Official.PublicMain where

import Prelude

import Effect (Effect)
import Example.Official.PublicSite (buildPublicSite, publicOutputDirectory)

main :: Effect Unit
main =
  buildPublicSite publicOutputDirectory

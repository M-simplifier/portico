module Example.Official.Main where

import Prelude

import Effect (Effect)
import Example.Official.Showcase (buildShowcase, showcaseOutputDirectory)

main :: Effect Unit
main =
  buildShowcase showcaseOutputDirectory

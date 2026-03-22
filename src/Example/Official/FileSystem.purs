module Example.Official.FileSystem
  ( removeTree
  ) where

import Prelude

import Effect (Effect)

foreign import removeTree :: String -> Effect Unit

module Test.Support.FileSystem
  ( pathExists
  , readTextFile
  , removeTree
  ) where

import Prelude

import Effect (Effect)

foreign import pathExists :: String -> Effect Boolean
foreign import readTextFile :: String -> Effect String
foreign import removeTree :: String -> Effect Unit

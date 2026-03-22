module Portico.Theme
  ( Theme
  , Palette
  , Spacing
  , Surface
  , ThemePatch
  , Typography
  , emptyThemePatch
  , patchTheme
  , theme
  , withPalette
  , withSpacing
  , withSurface
  , withRadius
  , withShadow
  , withTypography
  ) where

import Data.Maybe (Maybe(..))

type Palette =
  { background :: String
  , panel :: String
  , text :: String
  , mutedText :: String
  , accent :: String
  , border :: String
  }

type Typography =
  { display :: String
  , body :: String
  , mono :: String
  }

type Spacing =
  { pageInset :: String
  , pageTop :: String
  , pageBottom :: String
  , sectionGap :: String
  , stackGap :: String
  , cardPadding :: String
  , heroPadding :: String
  }

type Surface =
  { frameWidth :: String
  , brandRadius :: String
  , pillRadius :: String
  , headerSurface :: String
  , heroSurface :: String
  , quoteSurface :: String
  }

type Theme =
  { name :: String
  , palette :: Palette
  , spacing :: Spacing
  , surface :: Surface
  , typography :: Typography
  , radius :: String
  , shadow :: String
  }

type ThemePatch =
  { palette :: Maybe Palette
  , spacing :: Maybe Spacing
  , surface :: Maybe Surface
  , typography :: Maybe Typography
  , radius :: Maybe String
  , shadow :: Maybe String
  }

theme :: String -> Palette -> Typography -> Theme
theme name palette typography =
  { name
  , palette
  , spacing:
      { pageInset: "3rem"
      , pageTop: "4rem"
      , pageBottom: "5rem"
      , sectionGap: "3rem"
      , stackGap: "1.25rem"
      , cardPadding: "1.35rem"
      , heroPadding: "2rem"
      }
  , surface:
      { frameWidth: "72rem"
      , brandRadius: "0.9rem"
      , pillRadius: "999px"
      , headerSurface: "color-mix(in srgb,var(--panel) 88%,white)"
      , heroSurface: "linear-gradient(135deg,var(--panel) 0%,color-mix(in srgb,var(--accent) 6%,var(--panel)) 100%)"
      , quoteSurface: "linear-gradient(145deg,color-mix(in srgb,var(--accent) 8%,var(--panel)) 0%,var(--panel) 100%)"
      }
  , typography
  , radius: "20px"
  , shadow: "0 24px 80px rgba(0, 0, 0, 0.18)"
  }

emptyThemePatch :: ThemePatch
emptyThemePatch =
  { palette: Nothing
  , spacing: Nothing
  , surface: Nothing
  , typography: Nothing
  , radius: Nothing
  , shadow: Nothing
  }

patchTheme :: ThemePatch -> Theme -> Theme
patchTheme patch current =
  applyShadow
    (applyRadius
      (applySurface
        (applySpacing
          (applyTypography
            (applyPalette current)))))
  where
  applyPalette =
    case patch.palette of
      Just palette -> withPalette palette
      Nothing -> \currentTheme -> currentTheme

  applySpacing =
    case patch.spacing of
      Just spacing -> withSpacing spacing
      Nothing -> \currentTheme -> currentTheme

  applySurface =
    case patch.surface of
      Just surface -> withSurface surface
      Nothing -> \currentTheme -> currentTheme

  applyTypography =
    case patch.typography of
      Just typography -> withTypography typography
      Nothing -> \currentTheme -> currentTheme

  applyRadius =
    case patch.radius of
      Just radius -> withRadius radius
      Nothing -> \currentTheme -> currentTheme

  applyShadow =
    case patch.shadow of
      Just shadow -> withShadow shadow
      Nothing -> \currentTheme -> currentTheme

withPalette :: Palette -> Theme -> Theme
withPalette palette current =
  current { palette = palette }

withSpacing :: Spacing -> Theme -> Theme
withSpacing spacing current =
  current { spacing = spacing }

withSurface :: Surface -> Theme -> Theme
withSurface surface current =
  current { surface = surface }

withRadius :: String -> Theme -> Theme
withRadius radius current =
  current { radius = radius }

withShadow :: String -> Theme -> Theme
withShadow shadow current =
  current { shadow = shadow }

withTypography :: Typography -> Theme -> Theme
withTypography typography current =
  current { typography = typography }

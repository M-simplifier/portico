module Portico.Theme.Official
  ( OfficialPreset(..)
  , OfficialThemeOptions
  , officialTheme
  , officialThemeOptions
  , officialThemeWith
  , officialThemeWithAccent
  , officialThemeWithPalette
  , officialThemeWithPreset
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Portico.Theme (Palette, Spacing, Surface, Theme, ThemePatch, Typography, emptyThemePatch, patchTheme, theme, withPalette, withRadius, withShadow, withSpacing, withSurface)

data OfficialPreset
  = SignalPaper
  | CopperLedger
  | NightCircuit
  | BlueLedger

type OfficialThemeOptions =
  { preset :: OfficialPreset
  , accent :: Maybe String
  , palette :: Maybe Palette
  , typography :: Maybe Typography
  , spacing :: Maybe Spacing
  , surface :: Maybe Surface
  , radius :: Maybe String
  , shadow :: Maybe String
  }

officialTheme :: Theme
officialTheme = officialThemeWithPreset SignalPaper

officialThemeOptions :: OfficialPreset -> OfficialThemeOptions
officialThemeOptions preset =
  { preset
  , accent: Nothing
  , palette: Nothing
  , typography: Nothing
  , spacing: Nothing
  , surface: Nothing
  , radius: Nothing
  , shadow: Nothing
  }

officialThemeWith :: OfficialThemeOptions -> Theme
officialThemeWith options =
  patchTheme (themePatchFromOptions options) (baseThemeFromOptions options)

officialThemeWithPreset :: OfficialPreset -> Theme
officialThemeWithPreset =
  officialThemeWith <<< officialThemeOptions

officialThemeWithAccent :: String -> Theme
officialThemeWithAccent accent =
  officialThemeWith ((officialThemeOptions SignalPaper) { accent = Just accent })

officialThemeWithPalette :: Palette -> Theme
officialThemeWithPalette palette =
  officialThemeWith ((officialThemeOptions SignalPaper) { palette = Just palette })

baseThemeFromOptions :: OfficialThemeOptions -> Theme
baseThemeFromOptions options =
  applyColorOverride (presetTheme options.preset)
  where
  applyColorOverride currentTheme =
    case options.palette, options.accent of
      Just palette, _ -> withPalette palette currentTheme
      Nothing, Just accent ->
        withPalette (paletteFromAccent (paletteForPreset options.preset) accent) currentTheme
      Nothing, Nothing -> currentTheme

themePatchFromOptions :: OfficialThemeOptions -> ThemePatch
themePatchFromOptions options =
  emptyThemePatch
    { typography = options.typography
    , spacing = options.spacing
    , surface = options.surface
    , radius = options.radius
    , shadow = options.shadow
    }

presetTheme :: OfficialPreset -> Theme
presetTheme preset =
  buildOfficialTheme
    (nameForPreset preset)
    (paletteForPreset preset)
    (spacingForPreset preset)
    (surfaceForPreset preset)
    (typographyForPreset preset)
    (radiusForPreset preset)
    (shadowForPreset preset)

buildOfficialTheme :: String -> Palette -> Spacing -> Surface -> Typography -> String -> String -> Theme
buildOfficialTheme name palette spacing surface typography radius shadow =
  withShadow shadow
    (withRadius radius (withSurface surface (withSpacing spacing (theme name palette typography))))

nameForPreset :: OfficialPreset -> String
nameForPreset = case _ of
  SignalPaper -> "Signal Paper"
  CopperLedger -> "Copper Ledger"
  NightCircuit -> "Night Circuit"
  BlueLedger -> "Blue Ledger"

paletteForPreset :: OfficialPreset -> Palette
paletteForPreset = case _ of
  SignalPaper -> signalPaperPalette
  CopperLedger -> copperLedgerPalette
  NightCircuit -> nightCircuitPalette
  BlueLedger -> blueLedgerPalette

spacingForPreset :: OfficialPreset -> Spacing
spacingForPreset = case _ of
  SignalPaper -> signalPaperSpacing
  CopperLedger -> copperLedgerSpacing
  NightCircuit -> nightCircuitSpacing
  BlueLedger -> blueLedgerSpacing

surfaceForPreset :: OfficialPreset -> Surface
surfaceForPreset = case _ of
  SignalPaper -> signalPaperSurface
  CopperLedger -> copperLedgerSurface
  NightCircuit -> nightCircuitSurface
  BlueLedger -> blueLedgerSurface

typographyForPreset :: OfficialPreset -> Typography
typographyForPreset = case _ of
  SignalPaper -> sourceSerifTypography
  CopperLedger -> copperLedgerTypography
  NightCircuit -> publicSansTypography
  BlueLedger -> newsreaderTypography

radiusForPreset :: OfficialPreset -> String
radiusForPreset = case _ of
  SignalPaper -> "24px"
  CopperLedger -> "16px"
  NightCircuit -> "28px"
  BlueLedger -> "18px"

shadowForPreset :: OfficialPreset -> String
shadowForPreset = case _ of
  SignalPaper -> "0 30px 90px rgba(10, 16, 28, 0.24)"
  CopperLedger -> "0 28px 84px rgba(48, 26, 8, 0.18)"
  NightCircuit -> "0 36px 96px rgba(3, 7, 18, 0.42)"
  BlueLedger -> "0 30px 90px rgba(17, 24, 39, 0.12)"

signalPaperPalette :: Palette
signalPaperPalette =
  { background: "#f6f1e8"
  , panel: "#fffaf2"
  , text: "#111111"
  , mutedText: "#4f473f"
  , accent: "#0f766e"
  , border: "#d7cfc3"
  }

copperLedgerPalette :: Palette
copperLedgerPalette =
  { background: "#efe4d8"
  , panel: "#fbf5ee"
  , text: "#1f1712"
  , mutedText: "#6c6056"
  , accent: "#b45309"
  , border: "#dbc9b8"
  }

nightCircuitPalette :: Palette
nightCircuitPalette =
  { background: "#08111f"
  , panel: "#0f1a2e"
  , text: "#f7fbff"
  , mutedText: "#9fb0c7"
  , accent: "#ffb703"
  , border: "#23314d"
  }

blueLedgerPalette :: Palette
blueLedgerPalette =
  { background: "#eef3fb"
  , panel: "#fbfdff"
  , text: "#172033"
  , mutedText: "#58657e"
  , accent: "#2563eb"
  , border: "#d7dfec"
  }

paletteFromAccent :: Palette -> String -> Palette
paletteFromAccent base accent =
  { background: "color-mix(in srgb," <> accent <> " 5%," <> base.background <> ")"
  , panel: "color-mix(in srgb," <> accent <> " 3%," <> base.panel <> ")"
  , text: base.text
  , mutedText: "color-mix(in srgb," <> base.text <> " 42%," <> base.background <> ")"
  , accent
  , border: "color-mix(in srgb," <> accent <> " 18%," <> base.border <> ")"
  }

signalPaperSpacing :: Spacing
signalPaperSpacing =
  { pageInset: "3rem"
  , pageTop: "4rem"
  , pageBottom: "5rem"
  , sectionGap: "3rem"
  , stackGap: "1.25rem"
  , cardPadding: "1.35rem"
  , heroPadding: "2rem"
  }

signalPaperSurface :: Surface
signalPaperSurface =
  { frameWidth: "72rem"
  , brandRadius: "0.95rem"
  , pillRadius: "999px"
  , headerSurface: "color-mix(in srgb,var(--panel) 88%,white)"
  , heroSurface: "linear-gradient(135deg,var(--panel) 0%,color-mix(in srgb,var(--accent) 6%,var(--panel)) 100%)"
  , quoteSurface: "linear-gradient(145deg,color-mix(in srgb,var(--accent) 8%,var(--panel)) 0%,var(--panel) 100%)"
  }

copperLedgerSpacing :: Spacing
copperLedgerSpacing =
  { pageInset: "2.8rem"
  , pageTop: "3.7rem"
  , pageBottom: "4.6rem"
  , sectionGap: "2.7rem"
  , stackGap: "1.15rem"
  , cardPadding: "1.25rem"
  , heroPadding: "1.85rem"
  }

copperLedgerSurface :: Surface
copperLedgerSurface =
  { frameWidth: "68rem"
  , brandRadius: "0.45rem"
  , pillRadius: "0.55rem"
  , headerSurface: "linear-gradient(180deg,color-mix(in srgb,var(--accent) 6%,var(--panel)) 0%,var(--panel) 100%)"
  , heroSurface: "linear-gradient(160deg,color-mix(in srgb,var(--accent) 14%,var(--panel)) 0%,var(--panel) 58%,color-mix(in srgb,var(--text) 3%,var(--panel)) 100%)"
  , quoteSurface: "linear-gradient(180deg,color-mix(in srgb,var(--accent) 10%,var(--panel)) 0%,var(--panel) 100%)"
  }

nightCircuitSpacing :: Spacing
nightCircuitSpacing =
  { pageInset: "3.2rem"
  , pageTop: "4.8rem"
  , pageBottom: "5.6rem"
  , sectionGap: "3.35rem"
  , stackGap: "1.35rem"
  , cardPadding: "1.45rem"
  , heroPadding: "2.25rem"
  }

nightCircuitSurface :: Surface
nightCircuitSurface =
  { frameWidth: "76rem"
  , brandRadius: "1.2rem"
  , pillRadius: "1rem"
  , headerSurface: "linear-gradient(180deg,color-mix(in srgb,var(--panel) 92%,black) 0%,color-mix(in srgb,var(--accent) 6%,var(--panel)) 100%)"
  , heroSurface: "linear-gradient(135deg,color-mix(in srgb,var(--accent) 18%,var(--panel)) 0%,var(--panel) 55%,color-mix(in srgb,var(--text) 5%,var(--panel)) 100%)"
  , quoteSurface: "linear-gradient(145deg,color-mix(in srgb,var(--accent) 14%,var(--panel)) 0%,color-mix(in srgb,var(--text) 4%,var(--panel)) 100%)"
  }

blueLedgerSpacing :: Spacing
blueLedgerSpacing =
  { pageInset: "3rem"
  , pageTop: "4.2rem"
  , pageBottom: "5.1rem"
  , sectionGap: "3.1rem"
  , stackGap: "1.3rem"
  , cardPadding: "1.4rem"
  , heroPadding: "2rem"
  }

copperLedgerTypography :: Typography
copperLedgerTypography =
  { display: "\"Fraunces\", Georgia, serif"
  , body: "\"Public Sans\", \"Helvetica Neue\", sans-serif"
  , mono: "\"IBM Plex Mono\", monospace"
  }

blueLedgerSurface :: Surface
blueLedgerSurface =
  { frameWidth: "64rem"
  , brandRadius: "1.4rem"
  , pillRadius: "999px"
  , headerSurface: "linear-gradient(180deg,color-mix(in srgb,var(--accent) 4%,white) 0%,var(--panel) 100%)"
  , heroSurface: "linear-gradient(180deg,color-mix(in srgb,var(--accent) 8%,white) 0%,var(--panel) 52%,var(--panel) 100%)"
  , quoteSurface: "linear-gradient(180deg,color-mix(in srgb,var(--accent) 6%,white) 0%,var(--panel) 100%)"
  }

sourceSerifTypography :: Typography
sourceSerifTypography =
  { display: "\"Iowan Old Style\", \"Palatino Linotype\", serif"
  , body: "\"Source Serif 4\", Georgia, serif"
  , mono: "\"IBM Plex Mono\", monospace"
  }

publicSansTypography :: Typography
publicSansTypography =
  { display: "\"Space Grotesk\", \"Avenir Next\", sans-serif"
  , body: "\"Public Sans\", \"Helvetica Neue\", sans-serif"
  , mono: "\"IBM Plex Mono\", monospace"
  }

newsreaderTypography :: Typography
newsreaderTypography =
  { display: "\"Newsreader\", Georgia, serif"
  , body: "\"Source Serif 4\", Georgia, serif"
  , mono: "\"IBM Plex Mono\", monospace"
  }

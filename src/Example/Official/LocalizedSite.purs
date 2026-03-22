module Example.Official.LocalizedSite
  ( officialLocalizedSite
  ) where

import Example.Official.Site (officialSite)
import Example.Official.SiteJa (officialSiteJa)
import Portico (LocalizedSite, englishLocale, japaneseLocale, localizedSite, localizedVariant)

officialLocalizedSite :: LocalizedSite
officialLocalizedSite =
  localizedSite
    englishLocale
    [ localizedVariant englishLocale "English" "" officialSite
    , localizedVariant japaneseLocale "日本語" "ja" officialSiteJa
    ]

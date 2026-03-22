# Agent Quickstart

Portico is for published static sites. Start from `Portico`, stay on the semantic path, and keep theme concerns separate from content structure.

## Default Path

- Import from `Portico`.
- Model sites with `site`, `page`, `section`, blocks, navigation, and link helpers.
- Use `validateSite` before you treat output as publishable.
- Use `officialTheme` or the `officialThemeWith*` helpers instead of inventing a parallel theme system.
- Use `renderSite`, `emitSite`, or `emitMountedSite` for the build path, depending on whether you need rendered output or file emission.

## Practical Rule

Prefer semantic primitives over raw HTML or ad hoc markup.

If you keep needing the same custom shape, add or refine a Portico domain primitive instead of scattering local escape hatches.

## Minimal Example

```purescript
import Portico

siteDefinition =
  site "Portico"
    [ page "index" Landing "Home"
        [ namedSection "Intro"
            [ HeroBlock
                (hero "Published surfaces in PureScript."
                  "Portico focuses on content-first public sites.")
            ]
        ]
    ]

main = do
  let report = validateSite siteDefinition
  emitSite "site/dist" officialTheme siteDefinition
```

# Vision

## Thesis

Portico exists for one job:

- build published static sites in PureScript with a semantic DSL, a strong default look, and a workflow that is easy for high-agency AI agents to use correctly

This is not a general web framework. It is a narrower tool aimed at a real class of sites that appear constantly in practice and are still underserved by most typed frontend approaches.

## Domain

The domain is:

- public-facing, content-first web surfaces that can be deployed as static artifacts

That includes:

- official library or project sites
- documentation and learning sites
- product or service landing pages with light interaction
- release note and changelog pages
- essays, notes, and small publication sites
- portfolios, case studies, and archives
- event or campaign microsites

The domain does not include:

- product dashboards
- editors
- control consoles
- authenticated application shells
- high-frequency realtime interfaces

The right mental model is not "all websites". The right mental model is "published public surfaces".

## Why This Scope

"OSS official site" is too narrow. It produces a library that knows too much about one niche.

"Static site library" is too broad. It becomes a vague grab-bag with weak taste and weak defaults.

"Published public surfaces" is the useful middle. It is broad enough to cover real static-site work, but narrow enough that the DSL can still have strong opinions about page shape, information architecture, and visual pacing.

## DSL Direction

The core DSL should model things that are stable across this category:

- site
- page
- route slug
- section
- block
- navigation
- callout
- feature list
- prose
- media
- code sample
- timeline
- release list
- link grid

The core should not start from:

- raw HTML as the main story
- design-system classes as the main story
- marketing-funnel jargon as the whole story

The question is:

- what semantic vocabulary helps an AI produce a good public site quickly without first falling into unstructured layout code?

## Niche Support

Portico still needs escape hatches.

That support should come through:

- custom blocks
- theme extension points
- head/meta helpers
- validation and diagnostics for publishability
- optional asset hooks
- later, optional islands for light interaction

The niche story should be additive. It should not destroy the clarity of the default semantic path.

## AI For AI

Portico should be optimized for a highly capable implementation agent, not for minimizing syntax for beginners at any cost.

That means:

- one obvious import path
- one obvious official theme
- clear supported primitives
- honest boundaries
- semantic terms that compress real site structure
- validation passes that can catch broken static-site structure before publish time

Humans still matter, but the user experience should assume that much of the authoring work may be delegated to an AI that benefits from stronger structure and fewer ambiguous choices.

## Name

`Portico` is the front structure of a building: the public-facing entrance.

That matches the category better than names that imply generic layout, generic content, or generic frontend behavior. The library is for the public face of a thing.

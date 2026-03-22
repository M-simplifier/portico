# Release Checklist

This checklist is for repo-first pre-beta release hygiene.

Use `npm run verify` as the canonical release-oriented gate before treating a change as release-ready.

## Required

- [ ] Run `npm run verify`.
- [ ] Confirm `LICENSE` exists and is current before any public release. If it is missing or outdated, add or update it before publishing.
- [ ] Make sure public docs still describe Portico as a published static-site library, not as Asterism-lite.
- [ ] Keep package-distribution wording cautious unless the registry story has actually landed.

## Usually Also Needed

- [ ] Run `npm run check` alone when you want a faster typecheck-and-test loop during normal development.
- [ ] Run `npm run build:site` for changes that affect the public site or docs.
- [ ] Run `npm run build:pages` when release output needs Pages-style canonical URLs and publish-time files.
- [ ] If the public site uses localized bundles, confirm locale routes, `lang`, alternate links, and sitemap alternates still match the emitted output.
- [ ] Check that examples and docs still import from `Portico` and stay on the semantic path.

# Sample Lab

Build this example from the repository root:

```sh
npm run build:example
```

Generated output is written to `examples/official/dist`.

For the Portico-authored public site build, use:

```sh
npm run build:site
```

That output is written to `site/dist`, with the official site at the root, the chooser mounted under `lab/`, and the generated samples under `samples/`.

Current emitted files include:

- `index.html`
- `assets/portico.css`
- `samples/portico/index.html`
- `samples/northstar-cloud/index.html`
- `samples/atelier-north/index.html`
- `samples/mina-arai/index.html`
- `samples/signal-summit/index.html`
- `samples/field-notes/index.html`

Internal page links are emitted as relative `href`s, so the example works under subpath hosting instead of assuming deployment at `/`.

The source entry point lives in:

- `src/Example/Official/Main.purs`
- `src/Example/Official/Site.purs`
- `src/Example/Official/Showcase.purs`

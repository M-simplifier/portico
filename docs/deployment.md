# Deployment

Portico now has two different public-site build modes:

- `npm run build:site`
  Local/public-site build without forcing a canonical base URL. Useful for preview and dogfooding.
- `npm run build:pages`
  GitHub Pages-oriented build. This injects `PORTICO_BASE_URL`, emits canonical URLs for the official site, mounted sample lab, and samples, and writes `sitemap.xml`, `robots.txt`, and `404.html`.

## GitHub Pages

The repository includes `.github/workflows/deploy-pages.yml`.

That workflow:

- installs dependencies with `npm ci`
- runs `npm run build:pages`
- uploads `site/dist`
- deploys through the official Pages actions

### Base URL behavior

`npm run build:pages` resolves the base URL in this order:

1. `PORTICO_BASE_URL` if it is explicitly provided
2. a GitHub Pages default derived from `GITHUB_REPOSITORY`

That means:

- repository pages like `owner/repo` default to `https://owner.github.io/repo/`
- user or org pages like `owner/owner.github.io` default to `https://owner.github.io/`

### Custom domains

If the Pages site should publish under a custom domain, set a repository or environment variable named `PORTICO_BASE_URL` so the canonical URLs, sitemap, and robots output match the public domain.

Current example:

```text
PORTICO_BASE_URL=https://portico.example.com/
```

## Emitted publish-time files

The public build now emits:

- `index.html` and the rest of the official site
- `lab/index.html` and `lab/presets.html`
- `samples/...`
- `assets/portico.css`
- `404.html`
- `robots.txt`
- `sitemap.xml` when a base URL is available

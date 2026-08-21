# alikeapp.github.io

The legal and support site for **Alike**, served at <https://alikeapp.github.io/>.

The app itself lives in [`solokha-o/Alike`](https://github.com/solokha-o/Alike). This
repository holds only the published site, because an organization Pages site has to be
served from a repository named `<org>.github.io`.

## What is here

| Path | Serves |
|---|---|
| `index.md` | `/` — marketing page, the App Store listing's Marketing URL |
| `privacy.md` | `/privacy/` — Privacy Policy, shipped in the app and the listing |
| `support.md` | `/support/` — Support URL for the listing |
| `terms.md` | `/terms/` — Terms of Use for the listing |
| `uk/*.md` | the Ukrainian twin of each page |

Every page sets its own trailing-slash `permalink:`, so Jekyll writes directory-style
`index.html` files and the URLs above resolve without extensions.

## Deploying

`.github/workflows/pages.yml` builds with `actions/jekyll-build-pages` and deploys on
every push to `main`. Pages source must be set to **GitHub Actions** in
Settings → Pages.

The build **fails deliberately** if the rendered site references any third-party host.
The privacy policy claims Alike collects nothing and makes no network requests of its
own; an analytics script, a CDN asset or a remote web font would make that claim false.
Add a host to the allow-list in that workflow only if it is genuinely first-party.

## Link previews

`assets/img/og/<lang>.jpg` are the 1200×630 cards messengers show when someone pastes a
link. They are committed, not built: CI runs on Ubuntu, and the renderer needs
CoreGraphics and the macOS system fonts. Regenerate them on a Mac after changing the app
icon or a hero headline:

```
./scripts/make-og-images.sh
```

The script takes the locale list from `_config.yml` and each card's line of copy from
that locale's `hero.headline`, so nothing about it is hand-kept. Assertion 6 of
`scripts/check-site.sh` fails the build if a card goes missing, stops being the size the
pages declare, or if a page drops back to the small `summary` card — which is what made
Slack and iMessage unfurl these links with no image at all.

## Editing copy

The source copy is maintained in the app repository under `Docs/legal/`; see
`Docs/legal/README.md` there for the runbook. Keep the two in step — the app ships the
privacy URL in `SubscriptionConfiguration.swift`, and App Review rejects unreachable or
contradictory legal links.

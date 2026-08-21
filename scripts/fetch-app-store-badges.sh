#!/usr/bin/env bash
#
# Refreshes the localized "Download on the App Store" badges under
# assets/img/app-store-badge/.
#
#   ./scripts/fetch-app-store-badges.sh
#
# Apple's Identity Guidelines require the badge to be *their* artwork, used
# unmodified, so the badges are downloaded rather than drawn — and downloaded
# once and committed rather than fetched at build time, because the rendered
# site is not allowed to reference a third-party host (assertion 5 of
# scripts/check-site.sh) and a build that reached out to Apple on every deploy
# would break the moment that endpoint moved.
#
# en.svg is the US-English badge from developer.apple.com and is the fallback:
# _layouts/home.html serves it to any locale that has no file of its own, so a
# locale Apple does not publish a badge for still gets official artwork rather
# than a broken image.
#
# The locale map is repo-locale -> Apple locale. It is short enough to state
# outright; deriving it from _config.yml would only hide that pt-BR and zh-Hant
# do not follow the same pattern as the rest.

set -uo pipefail

cd "$(dirname "$0")/.."
OUT="assets/img/app-store-badge"
mkdir -p "$OUT"

LOCALES=(
  "uk:uk-ua"
  "de:de-de"
  "fr:fr-fr"
  "es:es-es"
  "pt-BR:pt-br"
  "it:it-it"
  "nl:nl-nl"
  "pl:pl-pl"
  "tr:tr-tr"
  "zh-Hant:zh-tw"
)

status=0

# The English badge is served straight from developer.apple.com, which is where
# Apple has published it for years; the rest come from the marketing toolbox,
# which is the only source of the localized artwork.
echo "==> en (developer.apple.com)"
if curl -fsSL --max-time 30 -o "$OUT/en.svg" \
     "https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg"; then
  echo "  ok  $OUT/en.svg"
else
  echo "::error::Could not download the English badge; $OUT/en.svg left as it was." >&2
  status=1
fi

for entry in "${LOCALES[@]}"; do
  lang="${entry%%:*}"
  apple="${entry##*:}"
  url="https://toolbox.marketingtools.apple.com/api/v2/badges/download-on-the-app-store/black/$apple"
  echo "==> $lang ($apple)"
  tmp="$(mktemp)"
  if curl -fsSL --max-time 30 -o "$tmp" "$url" && head -c 200 "$tmp" | grep -qi '<svg'; then
    mv "$tmp" "$OUT/$lang.svg"
    echo "  ok  $OUT/$lang.svg"
  else
    rm -f "$tmp"
    # Not fatal: the layout falls back to en.svg, which is still Apple's own
    # unmodified badge and so still within the guidelines.
    echo "  --  no badge for $apple; /$lang/ keeps the English fallback" >&2
  fi
done

exit "$status"

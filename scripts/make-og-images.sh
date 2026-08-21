#!/usr/bin/env bash
#
# Regenerates the link-preview cards under assets/img/og/, one per locale.
#
#   ./scripts/make-og-images.sh
#
# What a messenger shows when someone pastes https://alikeapp.github.io is an
# Open Graph card, and Slack, iMessage, Telegram and WhatsApp only render the
# large version of it for a roughly 1.91:1 image. The site used to point
# og:image at the square 1024x1024 app artwork; those clients answered by
# dropping the image and unfurling text only. Hence a drawn 1200x630 card.
#
# Like scripts/fetch-app-store-badges.sh this is a maintainer tool, not a build
# step: the cards are committed, and CI runs on ubuntu where neither Swift's
# CoreGraphics nor the system fonts exist. Run it after changing the app icon
# or any hero headline.
#
# Nothing here is hand-kept. The locales come from `languages` in _config.yml
# and each card's line of copy is that locale's `hero.headline` from
# _data/<lang>.yml, which is already translated eleven times over. A second
# hand-written list is exactly the drift scripts/check-site.sh exists to catch.

set -uo pipefail

cd "$(dirname "$0")/.."

CONFIG="_config.yml"
ICON="assets/img/og-image.jpg"      # the square app artwork, 1024x1024
OUT="assets/img/og"
RENDERER="scripts/make-og-image.swift"

status=0
fail() { printf 'make-og-images: %s\n' "$*" >&2; status=1; }

for required in "$CONFIG" "$ICON" "$RENDERER"; do
  [ -f "$required" ] || { echo "make-og-images: missing $required" >&2; exit 1; }
done

if ! command -v swift >/dev/null 2>&1; then
  echo "make-og-images: needs Swift and the macOS system fonts; run this on a Mac with Xcode's tools installed." >&2
  exit 1
fi

# The locale list, parsed out of `languages: [...]` exactly the way
# scripts/check-site.sh:56-79 does it — including the `|| [ -n "$lang" ]`,
# without which the unterminated last line silently drops the final locale.
languages_line=$(grep -E '^languages:[[:space:]]*\[' "$CONFIG" | head -1)
[ -n "$languages_line" ] || { echo "make-og-images: $CONFIG has no inline 'languages: [...]' list." >&2; exit 1; }

LANGS=()
while IFS= read -r lang || [ -n "$lang" ]; do
  [ -z "$lang" ] && continue
  LANGS+=("$lang")
done < <(printf '%s' "$languages_line" \
           | sed -E 's/^languages:[[:space:]]*\[//; s/\][[:space:]]*(#.*)?$//' \
           | tr ',' '\n' \
           | sed -E 's/^[[:space:]]*//; s/[[:space:]]*$//; s/^["'"'"']//; s/["'"'"']$//')

if [ "${#LANGS[@]}" -lt 2 ]; then
  echo "make-og-images: derived only ${#LANGS[@]} locale(s) from $CONFIG; the parse is wrong." >&2
  exit 1
fi

# `title:` at the top level of _config.yml is the product name on every card.
TITLE=$(grep -E '^title:' "$CONFIG" | head -1 | sed -E 's/^title:[[:space:]]*//; s/[[:space:]]*(#.*)?$//; s/^"//; s/"$//')
[ -n "$TITLE" ] || { echo "make-og-images: $CONFIG has no 'title:'." >&2; exit 1; }

# The headline nested under `hero:`. Scoped to that block rather than grepping
# the file for `headline:` — the FAQ and pricing sections have their own.
headline_for() {
  awk '
    /^hero:/            { inside = 1; next }
    inside && /^[^[:space:]]/ { exit }
    inside && /^[[:space:]]+headline:[[:space:]]*/ {
      sub(/^[[:space:]]+headline:[[:space:]]*/, "")
      sub(/^"/, ""); sub(/"[[:space:]]*$/, "")
      print
      exit
    }
  ' "$1"
}

mkdir -p "$OUT"
echo "Cards from $CONFIG (${#LANGS[@]} locales), icon $ICON:"

for lang in "${LANGS[@]}"; do
  data="_data/$lang.yml"
  if [ ! -f "$data" ]; then
    fail "$lang: no $data"
    continue
  fi

  headline=$(headline_for "$data")
  if [ -z "$headline" ]; then
    fail "$lang: $data has no hero.headline to put on the card"
    continue
  fi

  # The filename is the locale key, capitals and all — pt-BR.jpg, zh-Hant.jpg —
  # which is the contract assets/img/app-store-badge/<lang>.svg already follows
  # and what _includes/seo-meta.html appends page.lang to.
  if ! swift "$RENDERER" \
        --icon "$ICON" \
        --title "$TITLE" \
        --tagline "$headline" \
        --out "$OUT/$lang.jpg"; then
    fail "$lang: the renderer failed"
  fi
done

if [ "$status" -eq 0 ]; then
  echo "All ${#LANGS[@]} cards written to $OUT/."
else
  echo "Some cards were not written." >&2
fi
exit "$status"

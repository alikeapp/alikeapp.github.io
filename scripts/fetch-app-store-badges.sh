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

# Every download lands in a temporary file, is checked for being a whole SVG, and
# only then replaces the tracked badge. curl -f rejects an HTTP error status but
# not an HTML courtesy page served as 200, and a transfer cut halfway still
# leaves whatever arrived behind — writing straight to the tracked file would
# turn either into a committed, broken badge that the build cannot tell from a
# good one, because check-site.sh only asserts that the path resolves.
valid_svg() {
  local f="$1"
  [ -s "$f" ] || return 1

  # xmllint checks both well-formedness (including a complete closing tree) and
  # the actual document element. Looking for '<svg' anywhere in the response
  # would accept an HTML error page that happened to embed an inline SVG.
  if command -v xmllint >/dev/null 2>&1; then
    xmllint --noout "$f" >/dev/null 2>&1 || return 1
    [ "$(xmllint --xpath 'local-name(/*)' "$f" 2>/dev/null)" = "svg" ]
    return $?
  fi

  # macOS and the hosted CI images provide xmllint. Keep a conservative fallback
  # for minimal environments: it still requires the first document element to
  # be <svg> and the document to end with its closing tag, while allowing XML
  # declarations, comments and whitespace around the root.
  perl -0777 -e '
    my $s = <>;
    $s =~ s/^\x{FEFF}//;
    $s =~ s/\A(?:\s|<!--.*?-->|<\?.*?\?>)*//s;
    exit 1 unless $s =~ /\A<svg(?:\s[^>]*)?>/i;
    exit 1 unless $s =~ /<\/svg>\s*(?:<!--.*?-->|<\?.*?\?>|\s)*\z/is;
    exit 0;
  ' "$f"
}

# A small read-only entry point keeps the validator regression-testable without
# downloading badges. The normal no-argument path below remains unchanged.
if [ "${1:-}" = "--validate-svg" ]; then
  shift
  [ "$#" -gt 0 ] || exit 2
  status=0
  for f in "$@"; do
    valid_svg "$f" || status=1
  done
  exit "$status"
fi

install_badge() {
  local url="$1" dest="$2" tmp
  tmp="$(mktemp)"
  if ! curl -fsSL --max-time 30 -o "$tmp" "$url"; then
    rm -f "$tmp"
    return 1
  fi
  if ! valid_svg "$tmp"; then
    rm -f "$tmp"
    return 2
  fi
  # mktemp creates 0600 and mv keeps the mode, which would hand the site a badge
  # only its owner can read.
  chmod 644 "$tmp"
  if ! mv "$tmp" "$dest"; then
    rm -f "$tmp"
    return 3
  fi
}

# The English badge is served straight from developer.apple.com, which is where
# Apple has published it for years; the rest come from the marketing toolbox,
# which is the only source of the localized artwork.
echo "==> en (developer.apple.com)"
if install_badge "https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" "$OUT/en.svg"; then
  echo "  ok  $OUT/en.svg"
else
  # en.svg is every locale's fallback, so a failure here is the one that must be
  # loud: the previous file is still in place, unchanged and still valid.
  echo "::error::Could not install the English badge; $OUT/en.svg left as it was." >&2
  status=1
fi

for entry in "${LOCALES[@]}"; do
  lang="${entry%%:*}"
  apple="${entry##*:}"
  url="https://toolbox.marketingtools.apple.com/api/v2/badges/download-on-the-app-store/black/$apple"
  echo "==> $lang ($apple)"
  install_badge "$url" "$OUT/$lang.svg"
  case $? in
    0)
      echo "  ok  $OUT/$lang.svg"
      ;;
    1|2)
      # Not fatal: the layout falls back to en.svg, which is still Apple's own
      # unmodified badge and so still within the guidelines. Apple not publishing
      # a badge for a locale is a normal outcome of this script, not a failure of
      # it, and it is not worth a nonzero exit that a caller has to special-case.
      echo "  --  no usable badge for $apple; /$lang/ keeps the English fallback" >&2
      ;;
    *)
      # A move that failed is different in kind: the download worked, so the
      # badge exists and something about this working tree stopped it landing —
      # a read-only file, a full disk. Silently reporting the fallback would hide
      # that from anyone reading the log or the exit status.
      echo "::error::Downloaded the $apple badge but could not write $OUT/$lang.svg." >&2
      status=1
      ;;
  esac
done

exit "$status"

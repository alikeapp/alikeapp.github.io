#!/usr/bin/env bash
#
# The site's build gate. Runs against the *rendered* _site, so it checks what
# visitors actually get rather than what the sources look like.
#
#   ./scripts/check-site.sh [_site]
#
# Five assertions, in order of how expensive the failure is:
#
#   1. Locale matrix     — every locale publishes all four pages.
#   2. Internal links    — every site-relative href resolves to a real file.
#   3. hreflang          — alternates resolve, exactly one x-default, English.
#   4. Terms guardrails  — every Terms page still names Apple's Standard EULA
#                          and carries both subscription disclosures.
#   5. Third-party hosts — nothing external is referenced at all.
#
# (5) used to live inline in .github/workflows/pages.yml. It is here so one
# script is the whole gate and so a pull request can run the same checks the
# deploy runs.
#
# Assertion 4 is the one App Review cares about: Docs/legal/README.md in the app
# repo records that dropping the EULA reference or the disclosures from the Terms
# page is what turns this into a review problem. A translation that quietly loses
# them looks fine in a diff, which is why it is asserted rather than reviewed.

set -uo pipefail

SITE="${1:-_site}"
status=0

fail() { printf '::error::%s\n' "$*" >&2; status=1; }
pass() { printf '  ok  %s\n' "$*"; }

if [ ! -d "$SITE" ]; then
  echo "::error::No rendered site at '$SITE'. Build first." >&2
  exit 1
fi

# Derived from `languages` in _config.yml, not restated here: a second hand-kept
# list is exactly the drift this script exists to catch, and it would fail
# open — add a seventh locale, forget to add it here, and CI keeps checking six
# and reports green on a missing page.
#
# The directory is the URL path, which is lowercase, so pt-BR becomes pt-br. The
# default language lives at the root and has no directory at all.
CONFIG="${SITE_CONFIG:-$(cd "$(dirname "$0")/.." && pwd)/_config.yml}"
if [ ! -f "$CONFIG" ]; then
  echo "::error::Cannot read $CONFIG to derive the locale list." >&2
  exit 1
fi

languages_line=$(grep -E '^languages:[[:space:]]*\[' "$CONFIG" | head -1)
default_lang=$(grep -E '^default_lang:' "$CONFIG" | head -1 | sed -E 's/^default_lang:[[:space:]]*//; s/[[:space:]]*(#.*)?$//')
if [ -z "$languages_line" ] || [ -z "$default_lang" ]; then
  echo "::error::_config.yml must define an inline 'languages: [...]' list and 'default_lang'." >&2
  exit 1
fi

LOCALE_DIRS=()
# `|| [ -n "$lang" ]` catches the last item: the stream has no trailing newline,
# and a bare `read` discards an unterminated final line — which silently dropped
# pt-BR, the last locale in the list, and still reported green.
while IFS= read -r lang || [ -n "$lang" ]; do
  [ -z "$lang" ] && continue
  if [ "$lang" = "$default_lang" ]; then
    LOCALE_DIRS+=("")
  else
    LOCALE_DIRS+=("$(printf '%s' "$lang" | tr '[:upper:]' '[:lower:]')")
  fi
done < <(printf '%s' "$languages_line" \
           | sed -E 's/^languages:[[:space:]]*\[//; s/\][[:space:]]*(#.*)?$//' \
           | tr ',' '\n' \
           | sed -E 's/^[[:space:]]*//; s/[[:space:]]*$//; s/^["'"'"']//; s/["'"'"']$//')

if [ "${#LOCALE_DIRS[@]}" -lt 2 ]; then
  echo "::error::Derived only ${#LOCALE_DIRS[@]} locale(s) from $CONFIG; the parse is wrong." >&2
  exit 1
fi
printf 'Locales from _config.yml (%d):' "${#LOCALE_DIRS[@]}"
for d in "${LOCALE_DIRS[@]}"; do printf ' /%s' "$d"; done
printf '\n'

PAGES=("" "privacy" "terms" "support")

echo "==> 1. Locale matrix"
for loc in "${LOCALE_DIRS[@]}"; do
  for page in "${PAGES[@]}"; do
    path="$SITE"
    [ -n "$loc" ] && path="$path/$loc"
    [ -n "$page" ] && path="$path/$page"
    if [ -f "$path/index.html" ]; then
      pass "/${loc:+$loc/}${page:+$page/}"
    else
      fail "Missing page: /${loc:+$loc/}${page:+$page/} (expected $path/index.html)"
    fi
  done
done

# Resolve a site-absolute URL path to the file that serves it. Used by the
# hreflang check, whose targets are always absolute.
resolves() {
  local p="${1%%#*}"; p="${p%%\?*}"
  case "$p" in
    /*) ;;
    *) return 0 ;;   # not site-absolute; nothing to resolve
  esac
  [ -f "$SITE$p" ] && return 0
  [ -f "$SITE${p%/}/index.html" ] && return 0
  [ -f "$SITE$p/index.html" ] && return 0
  return 1
}

# Every reference a browser would actually fetch, extracted from one file.
# Restricting this to href/src="/..." would leave real forms unchecked, and the
# site uses two of them: the Terms pages link the Privacy Policy relatively
# (../privacy/), and every <picture> carries a srcset.
extract_refs() {
  local f="$1"
  grep -ohE '(href|src)="[^"]*"'  "$f" | sed -E 's/^(href|src)="//; s/"$//'
  grep -ohE "(href|src)='[^']*'"  "$f" | sed -E "s/^(href|src)='//; s/'\$//"
  # srcset is a comma-separated list of "<url> <descriptor>" pairs. Both quote
  # styles, for the same reason href and src take both: which one the generator
  # emits today is not a property this check should depend on.
  { grep -ohE 'srcset="[^"]*"' "$f" | sed -E 's/^srcset="//; s/"$//'
    grep -ohE "srcset='[^']*'" "$f" | sed -E "s/^srcset='//; s/'\$//"
  } | tr ',' '\n' | sed -E 's/^[[:space:]]+//; s/[[:space:]].*$//'
  # url(...) in a stylesheet or an inline <style> block.
  grep -ohE "url\([\"']?[^)\"']+[\"']?\)" "$f" | sed -E "s/^url\([\"']?//; s/[\"']?\)\$//"
}

# Collapse "." and ".." exactly as RFC 3986 remove_dot_segments does, which is
# what a browser and a static host both do.
#
# A ".." that would climb above the root is *discarded*, not an error: the
# browser clamps, so `../privacy/` on the home page is a request for /privacy/
# and returns 200. Treating the climb as broken would report those links as dead
# when they work — and this site's Terms pages link the Privacy Policy relatively.
#
# Clamping is also what keeps a link inside the build directory. The result never
# has a leading "..", so `$SITE$urlpath` cannot address anything outside $SITE —
# which matters because $SITE sits inside the repository, and resolving straight
# to a filesystem path let `../Gemfile` match a real file while being a 404 on the
# deployed site.
normalize_url_path() {
  local path="$1" out="" seg oldifs="$IFS"
  IFS='/'
  set -f                      # segments are literal, never globs
  for seg in $path; do
    case "$seg" in
      ''|.) ;;
      ..)  out="${out%/*}" ;;   # at root this is already "", so it stays there
      *)   out="$out/$seg" ;;
    esac
  done
  IFS="$oldifs"; set +f
  printf '%s' "${out:-/}"
}

# Resolve a reference the way a browser would: as a URL path relative to the page
# it appeared on, normalized first, and only then mapped onto the build output.
# Resolving straight to a filesystem path would let a link escape $SITE and match
# something in the repository that the deployed site does not serve.
ref_resolves() {
  local ref="${1%%#*}"; ref="${ref%%\?*}"
  local from="$2" urlpath page_dir
  [ -z "$ref" ] && return 0
  case "$ref" in
    http://*|https://*|//*|mailto:*|tel:*|data:*|javascript:*) return 0 ;;
  esac
  # The page's own URL directory, e.g. _site/de/terms/index.html -> /de/terms
  page_dir="${from#$SITE}"; page_dir="${page_dir%/*}"
  case "$ref" in
    /*) urlpath="$ref" ;;
    *)  urlpath="$page_dir/$ref" ;;
  esac
  urlpath="$(normalize_url_path "$urlpath")"
  [ -f "$SITE$urlpath" ] && return 0
  [ -f "$SITE${urlpath%/}/index.html" ] && return 0
  return 1
}

echo "==> 2. Internal links"
broken=0
while IFS= read -r f; do
  while IFS= read -r target; do
    [ -z "$target" ] && continue
    if ! ref_resolves "$target" "$f"; then
      fail "Broken internal link '$target' in ${f#$SITE}"
      broken=$((broken + 1))
    fi
  done < <(extract_refs "$f" | sort -u)
done < <(find "$SITE" \( -name '*.html' -o -name '*.css' \) )
[ "$broken" -eq 0 ] && pass "every href, src, srcset and url() resolves — absolute and relative"

echo "==> 3. hreflang"
while IFS= read -r html; do
  rel="${html#$SITE}"
  # Alternates are absolute URLs; compare on the path.
  while IFS= read -r href; do
    path="${href#https://alikeapp.github.io}"
    if ! resolves "$path"; then
      fail "hreflang points at a missing page: '$href' in $rel"
    fi
  done < <(grep -ohE '<link rel="alternate" hreflang="[^"]*" href="[^"]*"' "$html" \
             | sed -E 's/.*href="//; s/"$//' | sort -u)

  n_default=$(grep -c 'hreflang="x-default"' "$html")
  if [ "$n_default" -ne 1 ]; then
    fail "$rel has $n_default x-default tags, expected exactly 1"
  else
    default_href=$(grep -oE 'hreflang="x-default" href="[^"]*"' "$html" | sed -E 's/.*href="//; s/"$//')
    case "$default_href" in
      https://alikeapp.github.io/|https://alikeapp.github.io/privacy/|https://alikeapp.github.io/terms/|https://alikeapp.github.io/support/)
        ;;
      *)
        fail "$rel x-default is '$default_href', which is not an English URL"
        ;;
    esac
  fi
done < <(find "$SITE" -name 'index.html')
pass "alternates resolve and x-default points at English"

echo "==> 4. Terms guardrails"
# Per locale: a sentinel proving the Apple Standard EULA is still named, and a
# distinctive fragment of each of the two subscription disclosure paragraphs.
# The disclosure wording is owned by Docs/legal/subscription-disclosure.md in the
# app repo; these fragments are deliberately short so a wording fix there does
# not fail this build, while a dropped paragraph does.
# Matching is case-insensitive: the same phrase appears mid-sentence in the prose
# and capitalised in the plans table, and which one survives an edit is not the
# point of the check.
check_terms() {
  local dir="$1" eula="$2" renewal="$3" trial="$4"
  local f="$SITE${dir:+/$dir}/terms/index.html"
  local label="/${dir:+$dir/}terms/"
  local ok=1
  [ -f "$f" ] || { fail "$label missing, cannot check guardrails"; return; }
  grep -qiF "$eula" "$f"    || { fail "$label no longer names Apple's Standard EULA (looked for '$eula')"; ok=0; }
  grep -qiF "$renewal" "$f" || { fail "$label lost the auto-renewal disclosure (looked for '$renewal')"; ok=0; }
  grep -qiF "$trial" "$f"   || { fail "$label lost the free-trial disclosure (looked for '$trial')"; ok=0; }
  [ "$ok" -eq 1 ] && pass "$label EULA + both disclosures present"
}

check_terms ""      "Standard End User License Agreement"                        "renews automatically"        "7-day free trial"
check_terms "uk"    "Стандартною ліцензійною угодою з кінцевим користувачем"      "поновлюється автоматично"    "7 днів безкоштовно"
check_terms "de"    "Standard EULA"                                              "verlängert sich automatisch" "kostenlose Testphase"
check_terms "fr"    "licence utilisateur final standard"                         "renouvelle automatiquement"  "essai gratuit de 7 jours"
check_terms "es"    "licencia de usuario final estándar"                         "renueva automáticamente"     "prueba gratuita de 7 días"
check_terms "pt-br" "Contrato de Licença de Usuário Final Padrão"                "renovada automaticamente"    "7 dias de teste grátis"
# The it sentinel skips the apostrophe in "l'utente": kramdown turns it into a
# typographic ’ in the rendered page, and a straight one would never match.
check_terms "it"    "utente finale standard di Apple"                             "si rinnova automaticamente"  "prova gratuita di 7 giorni"
check_terms "nl"    "standaardlicentieovereenkomst voor eindgebruikers"           "automatisch verlengd"        "proefperiode van 7 dagen"
# Polish declines the phrase, so the sentinel is the part that does not change
# with case: "umowy licencyjnej" reads as the genitive the sentence needs.
check_terms "pl"    "licencyjnej użytkownika końcowego Apple"                     "odnawia się automatycznie"   "bezpłatny okres próbny"
check_terms "tr"    "Standart Son Kullanıcı Lisans Sözleşmesi"                    "otomatik olarak yenilenir"   "7 günlük ücretsiz deneme"
# zh-Hant has no case to be insensitive about, and no spaces: the fragments are
# short strings of Han characters that appear verbatim in the prose.
check_terms "zh-hant" "標準使用者授權合約"                                          "自動續訂"                     "7 天免費試用"

echo "==> 5. Third-party hosts"
# The privacy policy states that Alike collects nothing and makes no network
# requests of its own. A page that loaded an analytics script, a CDN asset, or a
# web font would make that claim false, so any external host is a build failure
# rather than a review comment. Subdomains count: support.apple.com is Apple,
# www.sitemaps.org is the sitemap namespace. XML/JSON-LD namespace URLs are
# identifiers, not fetches, but they are allow-listed so the check stays quiet.
#
# alikeapp.github.io is this site's own host: sitemap.xml and robots.txt emit
# absolute URLs, so omitting it fails the build on the site's own links.
hosts='alikeapp\.github\.io|apple\.com|w3\.org|schema\.org|sitemaps\.org'
allowed="([a-z0-9-]+\.)*($hosts)"
#
# The trailing (:port)? and delimiter are load-bearing, not tidiness. Matching
# the allow-list as a bare prefix accepts any host that merely *starts* with an
# allowed one, so https://apple.com.attacker.example/tracker.js and
# https://alikeapp.github.io.evil/x.css both read as allowed — the exact
# exfiltration this gate exists to stop. A hostname ends at a delimiter or at
# the end of the URL, and nowhere else. scripts/test-check-site.sh pins both.
boundary='(:[0-9]+)?([/?#]|$)'
# -I skips binary files. PNGs carry the string "apple.com" in colour-profile
# metadata, and on BSD grep that surfaces as a "Binary file ... matches" line
# that would otherwise be read as an external host.
external=$(grep -rhoIE 'https?://[^"'"'"' )<>]+' "$SITE" \
             | sort -u \
             | grep -vE "^https?://($allowed)$boundary" || true)
if [ -n "$external" ]; then
  fail "External hosts found in the built site:"
  printf '%s\n' "$external" >&2
else
  pass "no third-party hosts referenced"
fi

echo
if [ "$status" -eq 0 ]; then
  echo "All site checks passed."
else
  echo "Site checks FAILED." >&2
fi
exit "$status"

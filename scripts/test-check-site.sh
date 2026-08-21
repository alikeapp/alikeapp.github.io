#!/usr/bin/env bash
#
# Regression tests for scripts/check-site.sh.
#
#   ./scripts/test-check-site.sh [_site]
#
# A build gate is only worth the CI minutes if it fails when it should. Each case
# below copies the real rendered site, breaks exactly one thing, and asserts that
# check-site.sh notices — and that the message names the right problem, so a
# check that fails for an unrelated reason cannot pass for a working one.
#
# Using the real _site rather than a synthetic fixture keeps the sentinels in one
# place: check-site.sh owns them, and these tests do not restate them.

set -uo pipefail

SITE="${1:-_site}"
HERE="$(cd "$(dirname "$0")" && pwd)"
CHECK="$HERE/check-site.sh"
status=0
ran=0

if [ ! -d "$SITE" ]; then
  echo "::error::No rendered site at '$SITE'. Build first." >&2
  exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# A mutation that silently matched nothing leaves the site untouched, and the
# case then reports on unmodified input — green against the very bug it exists to
# catch. This has already happened twice here, so it is asserted rather than
# remembered: every case fingerprints the copy before and after.
fingerprint() {
  find "$1" -type f -exec cksum {} + | sort | cksum
}

apply_mutation() {
  local S="$1"; shift
  local before after
  before="$(fingerprint "$S")"
  ( S="$S"; eval "$@" )
  after="$(fingerprint "$S")"
  [ "$before" != "$after" ]
}

# expect_fail <name> <expected-message-fragment> <mutation-command...>
# The mutation runs with $S bound to a throwaway copy of the site.
expect_fail() {
  local name="$1" want="$2"; shift 2
  local S="$WORK/case"
  rm -rf "$S"; cp -R "$SITE" "$S"
  ran=$((ran + 1))
  if ! apply_mutation "$S" "$@"; then
    printf 'FAIL  %s — the mutation changed nothing; the case would report on unmodified input\n' "$name" >&2
    status=1
    return
  fi
  local out
  out="$("$CHECK" "$S" 2>&1)"
  local rc=$?
  if [ "$rc" -eq 0 ]; then
    printf 'FAIL  %s — check-site.sh passed a site that should fail\n' "$name" >&2
    status=1
  elif ! printf '%s' "$out" | grep -qF "$want"; then
    printf 'FAIL  %s — failed, but not for the expected reason\n      wanted: %s\n' "$name" "$want" >&2
    printf '%s\n' "$out" | grep '::error' | head -3 >&2
    status=1
  else
    printf 'ok    %s\n' "$name"
  fi
}

# Mutate a copy and require the checker to still pass. The mirror of expect_fail:
# a gate that rejects working input is as broken as one that accepts bad input,
# and only this direction catches an over-strict rule.
expect_pass_mutated() {
  local name="$1"; shift
  local S="$WORK/case"
  rm -rf "$S"; cp -R "$SITE" "$S"
  ran=$((ran + 1))
  if ! apply_mutation "$S" "$@"; then
    printf 'FAIL  %s — the mutation changed nothing; the case would report on unmodified input\n' "$name" >&2
    status=1
    return
  fi
  local out
  out="$("$CHECK" "$S" 2>&1)"
  if [ $? -eq 0 ]; then
    printf 'ok    %s\n' "$name"
  else
    printf 'FAIL  %s — check-site.sh rejected a site that should pass\n' "$name" >&2
    printf '%s\n' "$out" | grep '::error' | head -3 >&2
    status=1
  fi
}

expect_pass() {
  local name="$1"
  ran=$((ran + 1))
  if "$CHECK" "$SITE" >/dev/null 2>&1; then
    printf 'ok    %s\n' "$name"
  else
    printf 'FAIL  %s — the real site does not pass its own checks\n' "$name" >&2
    "$CHECK" "$SITE" 2>&1 | grep '::error' | head -5 >&2
    status=1
  fi
}

echo "==> baseline"
expect_pass "the rendered site passes"

echo "==> 1. locale matrix"
expect_fail "a missing locale page fails" \
  "Missing page: /es/terms/" \
  'rm -rf "$S/es/terms"'

# The matrix is derived from _config.yml rather than restated in the checker, so
# these two pin the derivation itself. Without them the list can quietly go short
# — it already did once, dropping the last locale and still reporting green.
echo "the locale list is derived, not hardcoded"
derived=$("$CHECK" "$SITE" 2>&1 | sed -n '1p')
ran=$((ran + 1))
if printf '%s' "$derived" | grep -qF "(11): / /uk /de /fr /es /pt-br /it /nl /pl /tr /zh-hant"; then
  printf 'ok    every locale in _config.yml reaches the matrix\n'
else
  printf 'FAIL  derived locale list is wrong: %s\n' "$derived" >&2
  status=1
fi

# One more locale in _config.yml must make the checker demand its pages.
SEVENTH="$WORK/_config-seventh.yml"
sed -E 's/^languages:.*/languages: [en, uk, de, fr, es, pt-BR, it, nl, pl, tr, zh-Hant, ja]/' "$HERE/../_config.yml" > "$SEVENTH"
ran=$((ran + 1))
# Capture before matching: under `pipefail` the checker's own non-zero exit —
# which is the point of this case — would decide the pipeline's status no matter
# what grep found.
seventh_out="$(SITE_CONFIG="$SEVENTH" "$CHECK" "$SITE" 2>&1)"
if printf '%s' "$seventh_out" | grep -qF "Missing page: /ja/"; then
  printf 'ok    adding a locale to _config.yml demands its pages\n'
else
  printf 'FAIL  a locale added to _config.yml was not checked — the matrix is not derived\n' >&2
  status=1
fi

echo "==> 2. internal links"
expect_fail "a dangling site-absolute link fails" \
  "Broken internal link '/de/nope/'" \
  'perl -0pi -e "s{href=\"/de/privacy/\"}{href=\"/de/nope/\"}" "$S/de/support/index.html"'

# The Terms pages link the Privacy Policy relatively, and every <picture> carries
# a srcset. Both were invisible to a check that only looked at href/src="/...".
expect_fail "a dangling relative link fails" \
  "Broken internal link '../nope/'" \
  'perl -0pi -e "s{href=\"\.\./privacy/\"}{href=\"../nope/\"}" "$S/de/terms/index.html"'
expect_fail "a dangling srcset candidate fails" \
  "Broken internal link '/assets/img/nope.avif'" \
  'perl -0pi -e "s{/assets/img/icon\.avif}{/assets/img/nope.avif}" "$S/index.html"'
expect_fail "a dangling single-quoted href fails" \
  "Broken internal link '/de/nope/'" \
  'perl -0pi -e "s{href=\"/de/privacy/\"}{href=\x27/de/nope/\x27}" "$S/de/support/index.html"'
expect_fail "a dangling stylesheet url() fails" \
  "Broken internal link '/assets/img/nope.png'" \
  'printf "\n.x { background: url(/assets/img/nope.png); }\n" >> "$S/assets/css/main.css"'
expect_fail "a single-quoted srcset candidate is not skipped" \
  "Broken internal link '/assets/img/nope.avif'" \
  'perl -0pi -e "s{srcset=\"[^\"]*\"}{srcset=\x27/assets/img/nope.avif 1x\x27}" "$S/uk/index.html"'

# $SITE lives inside the repository, so a link that climbs out of it can match a
# real file on disk while being a 404 on the deployed site. Resolution is by URL
# path, and ".." clamps at the root the way RFC 3986 says, so the climb lands
# back inside the site and the file next door is never reachable.
#
# Both cases plant the escape target next to the site copy first. Without that
# the link would fail merely because nothing is there, and the case would pass
# against the very bug it exists to catch.
expect_fail "a link climbing out of the site root does not reach the file next to it" \
  "Broken internal link '../outside.txt'" \
  'touch "$S/../outside.txt"; perl -0pi -e "s{href=\"/privacy/\"}{href=\"../outside.txt\"}" "$S/index.html"'
expect_fail "a deep climb does not reach the file next to the site root" \
  "Broken internal link '../../../outside.txt'" \
  'touch "$S/../outside.txt"; perl -0pi -e "s{href=\"/de/privacy/\"}{href=\"../../../outside.txt\"}" "$S/de/support/index.html"'

# The other half of clamping: a climb past the root is not broken, it is clamped.
# `../privacy/` on the home page is a request for /privacy/ and returns 200, so
# reporting it as a dead link would be a false positive on a working link.
expect_pass_mutated "a climb past the root clamps to a page that exists" \
  'perl -0pi -e "s{href=\"/privacy/\"}{href=\"../privacy/\"}" "$S/index.html"'
expect_pass_mutated "a deep climb past the root clamps to a page that exists" \
  'perl -0pi -e "s{href=\"/de/privacy/\"}{href=\"../../../de/privacy/\"}" "$S/de/index.html"'

echo "==> 3. hreflang"
expect_fail "an x-default pointing at a translation fails" \
  "x-default is" \
  'perl -0pi -e "s{(hreflang=\"x-default\" href=\"https://alikeapp.github.io)/privacy/}{\$1/de/privacy/}" "$S/privacy/index.html"'

echo "==> 4. terms guardrails"
expect_fail "dropping the EULA reference fails" \
  "no longer names Apple's Standard EULA" \
  'perl -0pi -e "s/Standard EULA/Apple-Vertrag/g" "$S/de/terms/index.html"'
expect_fail "dropping a subscription disclosure fails" \
  "lost the free-trial disclosure" \
  'perl -0pi -e "s/kostenlose Testphase/Gratiszeit/g" "$S/de/terms/index.html"'

echo "==> 5. third-party hosts"
expect_fail "a plain third-party asset fails" \
  "cdn.example.com" \
  'perl -0pi -e "s{href=\"/assets/css/main.css\"}{href=\"https://cdn.example.com/main.css\"}" "$S/index.html"'

# The allow-list used to be matched as a bare prefix, which accepted any host
# that merely started with an allowed one. Both of these read as allowed.
expect_fail "a host that only prefixes an allowed one fails (apple.com.*)" \
  "apple.com.attacker.example" \
  'perl -0pi -e "s{href=\"/assets/css/main.css\"}{href=\"https://apple.com.attacker.example/tracker.js\"}" "$S/index.html"'
expect_fail "a host that only prefixes our own fails (alikeapp.github.io.*)" \
  "alikeapp.github.io.evil" \
  'perl -0pi -e "s{href=\"/assets/css/main.css\"}{href=\"https://alikeapp.github.io.evil/x.css\"}" "$S/index.html"'

# github.com is allowed as one exact URL, not as a host: the source link is
# something the reader may click, while any other GitHub URL in the built site
# would be a subresource the browser fetches — which is what the privacy claim
# forbids, and which a host-wide exception used to wave through.
expect_fail "a GitHub-hosted subresource fails" \
  "github.com/track.js" \
  'perl -0pi -e "s{href=\"/assets/css/main.css\"}{href=\"https://github.com/track.js\"}" "$S/index.html"'
expect_fail "another path on the source repository fails" \
  "solokha-o/Alike/raw/main/evil.js" \
  'perl -0pi -e "s{href=\"/assets/css/main.css\"}{href=\"https://github.com/solokha-o/Alike/raw/main/evil.js\"}" "$S/index.html"'

# The boundary must not reject the legitimate cases it sits next to. The source
# link is in the real rendered site, so the baseline covers it passing; this adds
# the trailing-slash spelling of the same URL, which is equally legitimate.
expect_pass "a real Apple subdomain link still passes (support.apple.com)"
expect_pass_mutated "the source link still passes with a trailing slash" \
  'perl -0pi -e "s{href=\"https://github.com/solokha-o/Alike\"}{href=\"https://github.com/solokha-o/Alike/\"}" "$S/index.html"'

echo
if [ "$status" -eq 0 ]; then
  echo "All $ran check-site regression tests passed."
else
  echo "check-site regression tests FAILED." >&2
fi
exit "$status"

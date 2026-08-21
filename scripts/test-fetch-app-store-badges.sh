#!/usr/bin/env bash
#
# Regression tests for the SVG guard in fetch-app-store-badges.sh.
#
#   ./scripts/test-fetch-app-store-badges.sh

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
VALIDATE="$HERE/fetch-app-store-badges.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

status=0
ran=0

expect_valid() {
  local name="$1" file="$2"
  ran=$((ran + 1))
  if "$VALIDATE" --validate-svg "$file"; then
    printf 'ok    %s\n' "$name"
  else
    printf 'FAIL  %s — valid SVG was rejected\n' "$name" >&2
    status=1
  fi
}

expect_invalid() {
  local name="$1" file="$2"
  ran=$((ran + 1))
  if "$VALIDATE" --validate-svg "$file"; then
    printf 'FAIL  %s — invalid SVG was accepted\n' "$name" >&2
    status=1
  else
    printf 'ok    %s\n' "$name"
  fi
}

printf '%s\n' \
  '<?xml version="1.0" encoding="UTF-8"?>' \
  '<!-- Apple permits a comment before the document element. -->' \
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2 2">' \
  '  <path d="M0 0h2v2H0z"/>' \
  '</svg>' \
  > "$WORK/valid.svg"

printf '%s\n' \
  '<!doctype html><html><body>' \
  '<svg xmlns="http://www.w3.org/2000/svg"><path/></svg>' \
  '</body></html>' \
  > "$WORK/html-with-svg.svg"

printf '%s\n' \
  '<svg xmlns="http://www.w3.org/2000/svg"><path>' \
  > "$WORK/truncated.svg"

expect_valid "an XML-declared SVG with a leading comment passes" "$WORK/valid.svg"
expect_invalid "HTML wrapping an inline SVG fails" "$WORK/html-with-svg.svg"
expect_invalid "a truncated SVG fails" "$WORK/truncated.svg"

if [ "$status" -eq 0 ]; then
  echo "All $ran App Store badge regression tests passed."
else
  echo "App Store badge regression tests FAILED." >&2
fi
exit "$status"

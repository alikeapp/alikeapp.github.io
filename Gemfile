# Local preview only. Production builds use actions/jekyll-build-pages, which
# supplies its own github-pages toolchain — see .github/workflows/pages.yml.
#
#   cd site && BUNDLE_GEMFILE=Gemfile bundle exec jekyll serve
source "https://rubygems.org"

gem "jekyll", "~> 3.9"

# Jekyll 3.x defaults kramdown to GFM input, and kramdown 2.x moved that
# parser into its own gem. Without it `bundle exec jekyll build` dies on the
# first Markdown page. The github-pages toolchain used in CI ships it already.
gem "kramdown-parser-gfm", "~> 1.1"

# Multilocale Jekyll example — https://www.multilocale.com
#
# Deliberately small. Every gem here earns its place:
#
#   jekyll          the static-site generator
#   jekyll-polyglot the multi-language build: one source tree, one output
#                   tree per language, `site.active_lang` in Liquid
#
# That is the whole list. In particular there is no jekyll-sitemap: it would
# run once per language and leave three competing sitemaps, so sitemap.xml is
# a 30-line template in this repository instead. And there is no theme gem —
# the site is a handful of Liquid files and one stylesheet, with nothing
# hidden inside a gem you would have to fork to change.
#
# NB every gem in the :jekyll_plugins group is loaded whether or not it is
# listed under `plugins:` in _config.yml. Adding one here is enough to change
# the build.

source 'https://rubygems.org'

gem 'jekyll', '~> 4.4'

group :jekyll_plugins do
  gem 'jekyll-polyglot', '~> 1.13'
end

# Not bundled with macOS/Linux Ruby; Jekyll needs it to read time zones.
# `:windows` replaces the old :mingw/:mswin/:x64_mingw trio, which Bundler 4
# deprecates with a warning on every `bundle install`. It does not appear in
# Gemfile.lock's DEPENDENCIES, so the committed lockfile stays valid.
gem 'tzinfo-data', platforms: %i[windows jruby]

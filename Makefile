.PHONY: install build serve clean download import check

# The `multilocale` CLI is a Node package run with npx, never installed, so
# this variable is the only place its version is pinned — there is no
# package.json here to carry a dependency range. 1.3.1 is the floor: it is the
# first release whose `import` flattens a nested dictionary instead of storing
# it as an object and paying to machine-translate it *without* also escaping
# the keys of an already-flat dictionary, and the first that can set a
# project's `paths` (`projects update --paths`), which is what makes `download`
# write _data/<lang>/strings.json rather than translations/<lang>.json.
#
# Do not lower this to 1.3.0. That release escaped every key segment on the way
# up, so a catalogue written as `home.title` was stored as `home\.title` and no
# warning was printed; 1.3.1 decides escaping per dictionary and leaves a flat
# one untouched. This site's keys are flat `snake_case` with no dots, which is
# the only reason it escaped unharmed — a reader who copies the recipe and uses
# dotted keys would not.
#
# The range is a floor, not a guarantee: npx caches its install per spec
# string, so an `^1.3.0` here keeps re-running whatever it first resolved
# (1.3.0) even after 1.3.1 ships. Bumping the spec is what actually moves it.
#
# Keep the quotes in the recipes below. A caret is a glob operator under
# `setopt extendedglob` (oh-my-zsh turns it on), so an unquoted
# npx multilocale@^1.3.1 dies with `zsh: no matches found` before npx runs.
#
# Override to try a newer CLI without editing this file:
#   make download MULTILOCALE_VERSION=latest
MULTILOCALE_VERSION ?= ^1.3.1

# Install the Ruby gems into ./vendor/bundle (gitignored) so this example never
# touches your system gems.
install:
	bundle config set --local path vendor/bundle
	bundle install

# Build every language into _site/ (default language at the root, the rest in
# _site/<lang>/).
build:
	bundle exec jekyll build --trace

# http://127.0.0.1:4000 — the default language. The others are at
# /es/ and /it/. Jekyll's --livereload does not survive polyglot's forked
# per-language builds, so this is a plain serve.
serve:
	bundle exec jekyll serve --trace

clean:
	bundle exec jekyll clean

# Pull the translations from multilocale.com into _data/<lang>/strings.json.
# Reads multilocale.json for the project and the paths; run
# `npx "multilocale@$(MULTILOCALE_VERSION)" login` once first. The projectId
# committed here is this example's own project, in the maintainers'
# organization — with your own session it is a 404, so put your own project id
# in multilocale.json before this can work for you.
download:
	npx "multilocale@$(MULTILOCALE_VERSION)" download

# One-time onboarding for a codebase that already has dictionaries: uploads
# _data/<lang>/strings.json as phrases.
#
# `import` classifies the working directory as Android (an AndroidManifest.xml
# below it) or JavaScript (a package.json below it) and refuses to run in
# anything else — a Ruby site is neither, so running it here exits with
# `Could not detect project type`. Hence the throwaway staging tree: a
# package.json and a copy of _data/ in a temporary directory, which is enough
# for the JavaScript branch. The phrases land in the project either way, and
# `make download` writes them back here. `download` needs none of this.
#
# Run this EXACTLY once per project. Every run mints a fresh id per phrase and
# the API upserts by id, so a second run stores a second copy of every
# key/locale rather than merging.
import:
	@set -e; \
	staging=$$(mktemp -d); \
	trap 'rm -rf "$$staging"' EXIT; \
	printf '%s\n' '{ "name": "multilocale-import-staging", "private": true }' \
		> "$$staging/package.json"; \
	cp multilocale.json "$$staging/multilocale.json"; \
	cp -R _data "$$staging/_data"; \
	cd "$$staging" && npx "multilocale@$(MULTILOCALE_VERSION)" import

# What CI runs. A green `jekyll build` proves almost nothing here — polyglot
# can happily emit three copies of the same language — so this asserts that
# each language directory actually contains that language's words, that the
# untranslated post fell back, and that the shared files were written once.
check: build
	@set -e; \
	printf '%s\n' \
		'_site/index.html|One source tree' \
		'_site/es/index.html|Un solo código' \
		'_site/it/index.html|Un solo codice' \
		'_site/about/index.html|dictionary makes it worse' \
		'_site/es/about/index.html|diccionario de clave y valor' \
		'_site/it/about/index.html|dizionario chiave-valore' \
		'_site/it/blog/hreflang-for-static-sites/index.html|non è ancora stata tradotta' \
	| while IFS='|' read -r path needle; do \
		test -f "$$path" || { echo "FAIL missing $$path"; exit 1; }; \
		grep -q "$$needle" "$$path" \
			|| { echo "FAIL $$path does not contain '$$needle'"; exit 1; }; \
		echo "ok   $$path"; \
	done
	@set -e; \
	for path in _site/sitemap.xml _site/robots.txt _site/assets/css/style.css; do \
		test -f "$$path" || { echo "FAIL missing $$path"; exit 1; }; \
		echo "ok   $$path"; \
	done; \
	for path in _site/es/sitemap.xml _site/it/sitemap.xml _site/es/robots.txt \
		_site/es/assets/css/style.css; do \
		test ! -e "$$path" || { echo "FAIL $$path should not exist"; exit 1; }; \
		echo "ok   no $$path"; \
	done

# There is deliberately no publish target here. Mirroring this directory to its
# public repository is done from the waiterio monorepo with
# `node scripts/publishExample.mjs`, and that script is excluded from the
# mirror — so a target naming it would ship into the public repository pointing
# at a file that does not exist there. See AGENTS.md § Publishing.

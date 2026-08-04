.PHONY: install build serve clean download import check

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
# `npx multilocale@latest login` once first.
download:
	npx multilocale@latest download

# One-time onboarding for a codebase that already has dictionaries: uploads
# _data/<lang>/strings.json as phrases. Running it twice creates duplicates.
import:
	npx multilocale@latest import

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

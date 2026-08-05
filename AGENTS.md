# AGENTS.md

Instructions for coding agents working in this repository. Humans want
`README.md`.

## What this is

A three-language (en/es/it) Jekyll site. Interface strings come from
`_data/<lang>/strings.json`, written by the `multilocale` CLI. Prose (the about
page, blog posts) is one Markdown file per language, linked by a shared
`page_id` in front matter. `jekyll-polyglot` runs the build once per language.

## Commands

```bash
make install   # bundle install into ./vendor/bundle
make build     # jekyll build → _site/ (en at the root, es/ and it/ beneath)
make check     # build + assert each language really rendered  ← run this
make serve     # http://127.0.0.1:4000
make download  # pull translations from multilocale.com into _data/
make import    # push _data/ up — ONE TIME ONLY, per project; see below
```

`make check` is the gate. It builds, then asserts that each language directory
holds that language's words, that the untranslated post fell back, and that
`robots.txt`, `sitemap.xml` and the stylesheet exist exactly once. A green
`jekyll build` proves almost nothing: polyglot will happily emit three copies
of the same language if a `lang:` front-matter key is wrong.

## Adding or changing a user-visible string

1. Add the key to **all three** of `_data/{en,es,it}/strings.json`. English is
   the default locale, so a key missing there has no fallback.
2. Reference it as `{{ site.data.strings.your_key }}`.
3. `make check`.

Never hard-code a sentence in a layout or include. If you find one, that is a
bug.

Key style: flat `snake_case`, one level deep. A Multilocale phrase is a flat
key/value pair. On CLI 1.3.1 — the version this repository pins — `import`
flattens a nested dictionary into dot paths (`checkout.failed`), and
`--no-flatten` makes it refuse the file instead. Up to 1.2.2 it uploaded the
nested object verbatim, which was then machine-translated into garbage,
spending credits. Keep the files flat either way; `{{ site.data.strings.key }}`
is what the layouts read, and a dot in a key is awkward to reach from Liquid.

1.3.0 flattened, but escaped every key segment while doing it — including in a
dictionary that was already flat — so `home.title` became `home\.title` on the
server with no warning. These keys are flat `snake_case` with no dots, so
nothing here was corrupted, but do not lower the pin below 1.3.1 on that basis:
the recipe in `README.md` is copied by people whose keys do have dots.

File format: the committed files are byte-identical to what `multilocale
download` writes — keys sorted, two-space indent, trailing newline, and a
`"locale"` key the CLI injects. Preserve that or the next `download` produces a
noisy diff.

## Adding a page

- **Chrome** (no prose): one file, no `lang:`, no `page_id:`. Set `permalink:`
  explicitly, and `title_key:` if the `<title>` should come from the
  dictionary. Polyglot renders it under every language prefix. See
  `index.html`, `blog.html`, `404.html`.
- **Prose**: one file per language. Every one of them needs `lang:`,
  `page_id:` (identical across the set) and `permalink:`. See `about.md`,
  `es/about.md`, `it/about.md`.

A page that exists in some languages but not all falls back to the default
language and shows the banner driven by `page.missing_languages`.
`_posts/2026-07-21-hreflang-for-static-sites.md` has no Italian translation on
purpose — do not "fix" that; `make check` asserts the fallback still works.

## Adding a language

`_config.yml` `languages:`, `_data/languages.yml`, `_data/<lang>/strings.json`,
then extend the `check` target in the `Makefile`. No layout or include mentions
a language by name; if you find yourself adding one, that is the wrong fix.

## Traps that have already cost a build

- **A Liquid tag inside a Liquid comment breaks the build.** `{% comment %}`
  does not stop Liquid parsing tags it knows, so a `static_href` block spelled
  out inside a comment makes `endcomment` terminate the *wrong* block, and an
  unbalanced `{{` in a comment is a syntax error too. Mention tags by name in
  prose, never in their delimiters.
- **hreflang tags must stay on one line, shaped exactly
  `hreflang="en" href="…"`.** In a non-default pass polyglot rewrites absolute
  links pointing at `site.url`, and the only thing stopping it mangling the
  default-language alternate is a regex lookbehind for that literal text.
  Reformatting `_includes/head.html` across lines silently produces wrong
  hreflangs that still build.
- **`static_href` only protects root-relative links.** It emits `ferh=`, which
  is converted back to `href=` only for URLs starting with the baseurl. Wrap an
  external `https://` URL in it and the attribute ships as `ferh=`.
- **Every gem in the `:jekyll_plugins` group loads whether or not it is listed
  under `plugins:` in `_config.yml`.** Adding one to the Gemfile changes the
  build.
- **`exclude_from_localization` ≠ `exclude`.** The first keeps a file in the
  built site but writes it once, at the root (that is what makes there be one
  `sitemap.xml` and not three); the second keeps it out of the site entirely.
- **Jekyll's `date:` filter has no locale.** `%B` is "August" in every
  language. Translate the label; print ISO dates.

## Multilocale CLI

Run it with npx; this repository has no `package.json` and does not need one.
**1.3.1 is the minimum usable version.** There is no dependency file to carry
that pin, so the `Makefile` does, in one variable:

```make
MULTILOCALE_VERSION ?= ^1.3.1
```

Both CLI targets go through it, and so should anything you add. Three reasons
1.3.1 is the floor rather than a preference: `import` flattens nested
dictionaries instead of storing them as objects and billing to translate them;
it does that **without** escaping the keys of a dictionary that was already
flat, which 1.3.0 did (`home.title` → `home\.title`, silently, and `nested` was
reported false so nothing warned); and `projects update --paths` exists, which
is the only way to put `_data/%lang%/strings.json` on the project — and the
project's `paths` is what `download` actually obeys (see below).

The range is a floor, not a delivery mechanism. npx caches its install keyed on
the spec string, so leaving `^1.3.0` here can keep re-running the 1.3.0 tree it
first resolved long after 1.3.1 has shipped. Bumping the spec is what actually
moves a machine onto the fix.

**Quote the spec.** `^` is a glob operator under `setopt extendedglob`, which
oh-my-zsh enables, so a bare `npx multilocale@^1.3.1` dies with
`zsh: no matches found: multilocale@^1.3.1` before npx is even reached. Write
`npx "multilocale@^1.3.1"`. To try a newer CLI without editing anything:
`make download MULTILOCALE_VERSION=latest`.

`multilocale.json` supplies the project so no command drops into the
interactive project picker; since 1.2.2 that picker is skipped without a TTY
and the command fails fast instead, but on 1.2.0 and 1.2.1 it blocked a
non-interactive session forever.

The ids in `multilocale.json` are **real**: they point at
`multilocale-jekyll-example` (project `930e31054fb33780b73a0efe`, locales
en/es/it, `paths: ["_data/%lang%/strings.json"]`) in the maintainers'
organization. The committed `_data/<lang>/strings.json` files are exactly what
`multilocale download` writes from it — the round trip is closed, so a
`download` with no upstream change leaves `git status` clean, and a drift check
in CI would be meaningful.

Your own session cannot read that project: the API scopes every project lookup
to the caller's organization, so `download` returns 404 rather than writing
somebody else's strings over yours. Put your own `organizationId`/`projectId`
in `multilocale.json` before running any CLI command that touches the network.

Full command reference:

```bash
npx "multilocale@^1.3.1" --help
npx "multilocale@^1.3.1" schema            # the command tree as JSON
npx "multilocale@^1.3.1" skills get multilocale
```

Agent skills: `npx skills add multilocale/skills`. MCP server:
`https://mcp.multilocale.com/mcp`.

Known CLI behaviour worth knowing before you script it:

- **`download` is the only file command that runs unaided in a Ruby site.**
  `import`, `unused` and `localize` first classify the working directory as
  Android (an `AndroidManifest.xml` somewhere below it) or JavaScript (any
  `package.json` somewhere below it) and, finding neither here, exit with
  `Could not detect project type` and a reminder that Android needs an
  `AndroidManifest.xml` and JavaScript a `package.json`. `download` skips the
  check and works as-is.
  `make import` gets around it rather than around the CLI: it copies
  `multilocale.json` and `_data/` into a `mktemp -d` staging tree, drops a
  two-key stub `package.json` beside them, and runs `import` from there. The
  JavaScript branch is then satisfied, the paths still resolve (`import`
  matches files by suffix), the phrases land in the same project, and the
  staging tree is removed on exit. That is how this repository's 81 phrases
  (27 keys × en/es/it) were created, in one run.
- `signup` no longer leaves a nameless project behind: the account's first
  project is named after your email's local part and carries
  `defaultLocale: "en"`, `locales: ["en"]` and
  `paths: ["translations/%lang%.json"]`. Still `projects create` a real one for
  this site, **and pass `--paths '_data/%lang%/strings.json'`** — a project
  created without it has no `paths` at all, and `import` then falls back to
  `translations/%lang%.json`, finds nothing under it and uploads zero phrases.
  `projects update <id> --paths …` sets it after the fact.
- `download` resolves `project.paths || config.paths` — a value set on the
  server beats `multilocale.json`. The two agree here on purpose; if they ever
  disagree, the file in this repository is the one that is being ignored.
- `unused` greps only `.js/.jsx/.ts/.tsx/.cjs/.mjs` for usages, so it could
  never see a Liquid template even if it ran here.
- There is no YAML output format (`cjs`, `esm`, `json`, `js`, `swift` only),
  which is why the dictionaries are JSON rather than the `.yml` a Jekyll site
  would normally use.
- `import` is **not idempotent**, wherever you run it from: each run mints a
  fresh `_id` per phrase and the API upserts by `_id`, so importing twice stores
  two copies of every key/locale rather than merging. The Makefile's comment on
  the `import` target says the same thing.
- Older releases: 1.2.0 and 1.2.1 threw
  `Cannot read properties of undefined (reading 'forEach')` from
  `import`/`unused` whenever the project had no `paths`,
  `Cannot convert undefined or null to object` from `download` whenever a locale
  had no phrases yet, and `uuid2 is not a function` from `import` on the first
  phrase — meaning `import` had never once worked in a published build. All
  three are fixed in 1.2.2; nested-dictionary flattening and
  `projects update --paths` arrived in 1.3.0. Nothing below 1.3.0 can set this
  site up from scratch, and 1.3.0 itself must not be used: its flattener
  escaped every key segment of every dictionary, flat ones included, so
  `home.title` was stored as `home\.title` with no warning. 1.3.1 decides the
  escaping per dictionary. Nothing renames a phrase from the CLI, so keys
  corrupted that way need a direct `PUT /api/phrases` or a delete-and-reimport.
- Do not run write commands (`add`, `update`, `delete`, `share`, `localize`,
  `import`, `projects create`) against somebody else's session to try
  something out. They mutate real remote data and spend machine-translation
  credits.

## Publishing

`github.com/multilocale/jekyll-multi-language-website-example` is a read-only
mirror. It is written from the private waiterio monorepo, where this directory
lives as `multilocale/examples/jekyll`, by running

```bash
node scripts/publishExample.mjs --dry-run   # list what would ship
node scripts/publishExample.mjs             # mirror it
```

from that directory. There is no `make publish-repo` and no npm script on
purpose: `scripts/publishExample.mjs` is itself excluded from the mirror, so any
target naming it would ship into the public repository pointing at a file that
does not exist there. If you are reading this in a clone of the public
repository, that script is absent and nothing is publishable from here — the
flow only runs the other way.

The publisher enumerates files with `git ls-files --cached --others
--exclude-standard` and refuses a dirty working tree, so commit first, then
publish.

## Do not

- Depend on any `@multilocale/*` npm package. They are unmaintained and
  `@multilocale/react` is 404 on npm. The maintained package is `multilocale`,
  and it is a CLI, not a runtime library.
- Add a theme gem, a CSS framework, or a JavaScript build step. The point of
  this repository is that a reader can hold all of it in their head.
- Edit `_data/<lang>/strings.json` to say something the project on
  multilocale.com does not — the next `download` will overwrite it.

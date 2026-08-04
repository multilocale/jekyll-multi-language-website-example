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

Key style: flat `snake_case`, one level deep. `multilocale import` accepts flat
JSON only — a nested object is stored as an object and then machine-translated
into garbage, spending credits.

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

Run it with `npx multilocale@latest <command>`; this repository has no
`package.json` and does not need one. `multilocale.json` supplies the project
so no command drops into the interactive project picker — that picker hangs
non-interactive sessions.

The two placeholders in `multilocale.json` are placeholders on purpose. A
`download` against them fails fast with a 404 instead of writing files from
somebody else's project.

Full command reference:

```bash
npx multilocale@latest --help
npx multilocale@latest schema              # the command tree as JSON
npx multilocale@latest skills get multilocale
```

Agent skills: `npx skills add multilocale/skills`. MCP server:
`https://mcp.multilocale.com/mcp`.

Known CLI behaviour worth knowing before you script it:

- `signup` creates a nameless bootstrap project with no locales and no paths.
  Always `projects create` a real one.
- `import` and `unused` read `paths` from the **project** and throw
  `Cannot read properties of undefined (reading 'forEach')` when it is unset.
- `download` resolves `project.paths || config.paths` — a value set on the
  server beats `multilocale.json`.
- `unused` greps only `.js/.jsx/.ts/.tsx/.cjs/.mjs`, so it reports every key
  here as unused. It is not.
- There is no YAML output format (`cjs`, `esm`, `json`, `js`, `swift` only),
  which is why the dictionaries are JSON rather than the `.yml` a Jekyll site
  would normally use.
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

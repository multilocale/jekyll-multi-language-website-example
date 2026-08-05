# Jekyll multi-language website example

A working three-language Jekyll site — English, Spanish, Italian — whose
translations are managed on [multilocale.com](https://www.multilocale.com) and
pulled into the repository as JSON files by the `multilocale` CLI.

It is built so that the two halves of a translated site stay apart:

|                          | Where it lives                                          | Who edits it                      |
| ------------------------ | ------------------------------------------------------- | --------------------------------- |
| **Interface strings**    | `_data/en/strings.json`, `_data/es/…`, `_data/it/…`      | translators, via multilocale.com  |
| **Prose** (pages, posts) | one Markdown file per language, linked by `page_id`      | writers, in the repository        |

Clone it and it builds offline: the dictionaries are committed, so you do not
need an account to see it work.

```bash
git clone https://github.com/multilocale/jekyll-multi-language-website-example.git
cd jekyll-multi-language-website-example
make install
make serve
```

Then open <http://127.0.0.1:4000/> (English), <http://127.0.0.1:4000/es/> and
<http://127.0.0.1:4000/it/>.

## Requirements

Ruby 3.2 or newer — this example is developed and CI-tested on **Ruby 4.0**
(see `.ruby-version`), with **Jekyll 4.4** and **jekyll-polyglot 1.13**. Those
two gems and a Windows-only time-zone shim are the entire `Gemfile`: no theme
gem, no Sass, and no Node.js needed to build the site. The `multilocale` CLI
is a Node package, but it is only needed to *change* the translations, and is
run with `npx` rather than installed — **version 1.3.1 or newer**, pinned once
in the `Makefile` as `MULTILOCALE_VERSION ?= ^1.3.1` because a Ruby project has
no dependency file to put it in. Quote it if you type it yourself:
`npx "multilocale@^1.3.1" …`, since `^` is a glob operator in zsh with
`extendedglob` on.

**Do not use 1.3.0.** It escaped every segment of every key on upload, so a
dictionary written the ordinary way — `home.title`, `nav.blog` — was stored as
`home\.title` and `nav\.blog`, silently, with no warning. 1.3.1 decides that
escaping per dictionary and leaves an already-flat one alone. This site's keys
are flat `snake_case` with no dots, which is the only reason its data survived
1.3.0 untouched; a dictionary that uses dotted keys would not have.

On macOS, `/usr/bin/ruby` is 2.6 and cannot run any of this. Install a current
Ruby (`brew install ruby`, `rbenv`, `asdf`, …) and make sure it is ahead of
`/usr/bin` on your `PATH` — `ruby --version` should print 3.2 or newer before
you run `make install`.

## What is where

```
_config.yml                 languages, default_lang, exclude_from_localization
_data/en/strings.json       ← written by `multilocale download`
_data/es/strings.json       ←
_data/it/strings.json       ←
_data/languages.yml         endonyms for the language picker (not translated)
_includes/head.html         <title>, canonical, hreflang, x-default
_includes/header.html       navigation + language picker
_includes/language-picker.html
_includes/footer.html
_layouts/{default,home,page,post,blog}.html
index.html                  one file → /, /es/, /it/
blog.html                   one file → /blog/, /es/blog/, /it/blog/
404.html                    one file → /404.html, /es/404.html, /it/404.html
about.md  es/about.md  it/about.md      three files, one page_id
_posts/                     one file per language per post
sitemap.xml                 multilingual sitemap, built once
robots.txt
multilocale.json            project id + where download writes the files
Makefile                    install / build / serve / check / download / import
```

## Two ways to translate, and when to use which

**A dictionary** for anything that is chrome: navigation, buttons, the 404
page, a headline. `_layouts/home.html` contains

```liquid
<h1>{{ site.data.strings.home_headline }}</h1>
```

and never contains the sentence itself. One source file renders under every
language prefix, which is why `index.html`, `blog.html` and `404.html` have no
per-language copies at all.

`site.data.strings` is not a file on disk. jekyll-polyglot merges
`_data/<default_lang>/` and then `_data/<active_lang>/` into the top level of
`site.data` before rendering, so `strings` is the active language laid over the
default one. **A key you have not translated yet renders in the default
language rather than as an empty string** — an incomplete translation makes the
site less translated, never broken.

**A file per language** for prose: `about.md`, `es/about.md`, `it/about.md`.
They share a `page_id: about` in their front matter, which is how polyglot
knows they are the same page. Posts do the same, and because a post's slug
should be readable in its own language, the three translations of one post have
three different permalinks:

```
/blog/translating-a-jekyll-site/
/es/blog/traducir-un-sitio-jekyll/
/it/blog/tradurre-un-sito-jekyll/
```

`page_id` is what keeps `hreflang` and the language picker pointing at the
right one.

A post with no translation in the current language falls back to the default
language, and the layout says so — `_posts/2026-07-21-hreflang-for-static-sites.md`
has no Italian version on purpose. Open
<http://127.0.0.1:4000/it/blog/hreflang-for-static-sites/> and the banner above
it comes from `page.missing_languages`.

## The workflow, end to end

The `multilocale.json` committed here already holds real ids — they point at
this example's own project in the maintainers' organization, which is how the
committed dictionaries stay verifiably in sync with it. Every project lookup is
scoped to the caller's organization, so with *your* session those ids are a
404, not somebody else's data. Replace them in step 2.

### 1. Create an account

No browser needed. The generated password is printed exactly once:

```bash
npx "multilocale@^1.3.1" signup --email you@example.com --json
```

If you already have one:

```bash
npx "multilocale@^1.3.1" login
```

### 2. Create a project — do not use the one signup made

`signup`'s bootstrap project is named after your email and carries
`locales: ["en"]` and `paths: ["translations/%lang%.json"]` — the wrong shape
for this site. Make a real one, and give it the paths in the same breath:

```bash
npx "multilocale@^1.3.1" projects create my-website \
  --locales en,es,it \
  --default-locale en \
  --paths '_data/%lang%/strings.json'
```

`--paths` is not optional bookkeeping. `import` and `download` read the paths
off the **project**, and a project that has none makes `import` look under
`translations/%lang%.json`, find nothing, and upload zero phrases. If you
already created the project without them:
`npx "multilocale@^1.3.1" projects update my-website --paths '_data/%lang%/strings.json'`.

Copy the ids it prints into `multilocale.json`, over the ones committed here:

```json
{
  "organizationId": "…",
  "projectId": "…",
  "format": "json",
  "extension": "json",
  "paths": ["_data/%lang%/strings.json"]
}
```

`multilocale.json` is what makes every later command run with no flags. Without
it the CLI stops to ask which project you meant, which hangs CI and agents.

### 3. Push the strings that are already here

```bash
make import
```

This uploads `_data/en/strings.json`, `_data/es/strings.json` and
`_data/it/strings.json` as phrases and machine-translates anything a locale is
missing — nothing, here, because all three files carry the same 27 keys.
**Run it once.** A second run creates duplicate rows rather than merging: each
run mints a fresh id per phrase and the API upserts by id.

It is a `make` target rather than a bare `npx … import` because `import`
refuses to run in a directory it cannot classify as an Android or JavaScript
project — it looks for an `AndroidManifest.xml` or a `package.json` below the
working directory, and a Jekyll site has neither, so it exits with
`Could not detect project type`. The target copies `multilocale.json` and
`_data/` into a temporary directory, puts a stub `package.json` beside them,
runs `import` there, and deletes it afterwards. `download` has no such check
and runs here directly.

### 4. Work on the translations

In the web app, or from the terminal:

```bash
npx "multilocale@^1.3.1" phrases list -l it
npx "multilocale@^1.3.1" add "checkout_button" "Buy now"
npx "multilocale@^1.3.1" update "nav_blog" "Diario" -l es
npx "multilocale@^1.3.1" localize fr,de        # add locales, translate into them
```

`add` machine-translates into every configured locale. For a short or ambiguous
string, say what it means — the model has nothing else to go on:

```bash
npx "multilocale@^1.3.1" add "book" "Book" \
  --context "Verb on a button: reserve an appointment, not the noun"
```

### 5. Pull the files back and commit them

```bash
make download     # npx "multilocale@^1.3.1" download
git diff _data/
```

`download` writes one file per locale in the project, at the project's `paths`,
sorted, two-space indented, with a trailing newline. The files in this
repository are byte-identical to what it produces — they were written by it —
so a `download` with no upstream change leaves `git status` clean.

Commit the result. The committed dictionaries are what make `git clone && make
build` work with no network, no credentials and no account — the sync step is
how these files *change*, not how they *arrive*.

### 6. Adding a language

```bash
npx "multilocale@^1.3.1" localize pt
```

then add `pt` to `languages:` in `_config.yml`, add `pt: Português` to
`_data/languages.yml`, and `make download`. Nothing else: no layout, include or
page mentions a language by name.

## Deploying

`make build` writes `_site/`, which is a plain directory of static files —
GitHub Pages, Netlify, Cloudflare Pages, S3, anything.

Two things to change before you do:

- **`url:` in `_config.yml`.** It is `https://example.com` here. Every
  `canonical` and `hreflang` this site emits is absolute, and a wrong `url:`
  produces a site that looks perfect in a browser and is invisible in a search
  index.
- **`title:`, and the GitHub link in `_includes/footer.html`.**

GitHub Pages' built-in Jekyll runs in safe mode with a fixed plugin list that
does not include jekyll-polyglot, so build the site in Actions and publish
`_site/` as an artifact rather than letting Pages build it. The workflow in
`.github/workflows/ci.yml` already produces exactly that artifact.

## Verifying a change

```bash
make check
```

builds every language and then asserts that each language directory really
contains that language's words, that the untranslated post fell back, and that
`robots.txt`, `sitemap.xml` and the stylesheet were each written exactly once.
A bare `jekyll build` proves very little here — polyglot will happily emit
three copies of the same language if a `lang:` is wrong.

## Things that will bite you

- **A Multilocale phrase is a flat key/value pair.** Since 1.3.0 `import`
  flattens a nested dictionary into dot-path keys (`home.step_1.title`), and
  `--no-flatten` makes it refuse the file instead; up to 1.2.2 it stored the
  object verbatim and then machine-translated it into garbage, spending
  credits. Keep dictionaries one level deep either way — use
  `home_step_1_title`, not `home: { step_1: { title } }` — because a dot-path
  key is awkward to read back from Liquid.
- **1.3.0 escaped keys it should not have.** That first flattener escaped every
  segment of every key, including in a dictionary that was already flat, so
  `home.title` uploaded as `home\.title` and nothing warned about it. Use
  **1.3.1 or newer**, which decides escaping per dictionary: a nested one is
  escaped so it can be split back apart exactly, a flat one passes through
  untouched. If you ran `import` on 1.3.0 and see backslashes in your keys, the
  CLI cannot rename a phrase — repair them with `PUT /api/phrases`, or delete
  the keys and import again.
- **`download` prefers the project's `paths` over `multilocale.json`.** If the
  project on the server has `paths` set, that value wins and your local
  configuration is ignored.
- **`download` writes a `"locale"` key into every file.** It is not a bug and
  not a phrase; the footer of this site prints it as a sanity check.
- **`multilocale unused` only greps `.js/.jsx/.ts/.tsx/.cjs/.mjs`.** It will
  report every key in this repository as unused, because they are referenced
  from Liquid. Ignore it here.
- **There is no YAML output format.** The CLI writes `json`, `js`, `cjs`, `esm`
  or Apple `.strings`. That is why the dictionaries are `_data/<lang>/strings.json`
  rather than the `_data/<lang>.yml` a Jekyll site would normally use — Jekyll
  reads JSON data files natively, so nothing is lost.
- **Do not write a Liquid tag inside a Liquid comment.** `{% comment %}` does
  not stop Liquid from parsing tags it knows, so a `static_href` block written
  out in full inside a comment makes the build fail with a syntax error
  pointing at the wrong line.
- **Jekyll's `date:` filter has no locale.** `%B` is "August" in every
  language. This site translates the *label* and prints ISO dates.
- **`exclude_from_localization` is not `exclude`.** The first keeps a file in
  the built site but writes it only once, at the root; the second keeps it out
  of the site entirely.

## Related

- [`multilocale` CLI on npm](https://www.npmjs.com/package/multilocale) —
  `npx "multilocale@^1.3.1" --help`
- [Multilocale developer docs](https://www.multilocale.com/developers/)
- [jekyll-polyglot](https://github.com/untra/polyglot)
- Other examples: [Next.js](https://github.com/multilocale/nextjs-multi-language-website-example),
  [Remix](https://github.com/multilocale/remix-multi-language-website-example),
  [Gatsby](https://github.com/multilocale/gatsby-multi-language-website-example),
  [Lingui](https://github.com/multilocale/linguijs-multi-language-website-example),
  [iOS](https://github.com/multilocale/ios-multi-language-app-example),
  [Android](https://github.com/multilocale/android-multi-language-app-example)

## License

[MIT](LICENSE)

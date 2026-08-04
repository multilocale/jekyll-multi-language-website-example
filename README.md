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
run with `npx` rather than installed.

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

### 1. Create an account

No browser needed. The generated password is printed exactly once:

```bash
npx multilocale@latest signup --email you@example.com --json
```

If you already have one:

```bash
npx multilocale@latest login
```

### 2. Create a project — do not use the one signup made

`signup` leaves behind a nameless bootstrap project with no locales, no default
locale and no paths, and several CLI commands throw on it. Make a real one:

```bash
npx multilocale@latest projects create my-website \
  --locales en,es,it \
  --default-locale en
```

Copy the id it prints into `multilocale.json`, replacing both placeholders:

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
npx multilocale@latest import
```

This uploads `_data/en/strings.json`, `_data/es/strings.json` and
`_data/it/strings.json` as phrases and machine-translates anything a locale is
missing. **Run it once.** A second run creates duplicate rows rather than
merging.

### 4. Work on the translations

In the web app, or from the terminal:

```bash
npx multilocale@latest phrases list -l it
npx multilocale@latest add "checkout_button" "Buy now"
npx multilocale@latest update "nav_blog" "Diario" -l es
npx multilocale@latest localize fr,de          # add locales, translate into them
```

`add` machine-translates into every configured locale. For a short or ambiguous
string, say what it means — the model has nothing else to go on:

```bash
npx multilocale@latest add "book" "Book" \
  --context "Verb on a button: reserve an appointment, not the noun"
```

### 5. Pull the files back and commit them

```bash
npx multilocale@latest download     # or: make download
git diff _data/
```

`download` writes one file per locale in the project, at the `paths` from
`multilocale.json`, sorted, two-space indented. The files in this repository
are byte-identical to what it produces, so a `download` with no upstream
changes leaves `git status` clean.

Commit the result. The committed dictionaries are what make `git clone && make
build` work with no network, no credentials and no account — the sync step is
how these files *change*, not how they *arrive*.

### 6. Adding a language

```bash
npx multilocale@latest localize pt
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

- **`multilocale import` accepts flat JSON only.** A nested object is stored as
  an object and then machine-translated into garbage, spending credits. Keep
  dictionaries one level deep; use `home_step_1_title`, not
  `home: { step_1: { title } }`.
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
  `npx multilocale@latest --help`
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

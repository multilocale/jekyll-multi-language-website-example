---
layout: post
lang: en
page_id: hreflang-for-static-sites
title: The three tags a multi-language static site has to get right
description: canonical, hreflang and x-default — and the sitemap that ties them together.
---

A translated page that search engines cannot connect to its siblings competes
with them instead. Three tags prevent that: a `rel="canonical"` pointing at the
current language's own URL, one `rel="alternate" hreflang="…"` per translation,
and an `hreflang="x-default"` pointing at the default language. All three are
emitted from `_includes/head.html`, which reads each translation's real
permalink out of `page.permalink_lang` — so the Spanish alternate stays correct
even though its slug shares no characters with the English one.

`jekyll-polyglot` ships a tag that does most of this, `i18n_headers`, and this
site deliberately does not use it. It emits an alternate only for languages
that have their own source file. That is right for the pages whose prose is
translated, and wrong for every page whose words come from a dictionary: the
home page, the blog index and 404 have one source file between all three
languages, so the tag would have declared them English-only while `/es/` and
`/it/` copies of them sat in the output directory.

`sitemap.xml` says the same thing a second way: every URL is listed once, with
`xhtml:link` alternates naming its translations. It is built only in the
default-language pass — `robots.txt` and `sitemap.xml` are in
`exclude_from_localization`, because a sitemap that exists three times at three
prefixes is worse than no sitemap at all.

One prerequisite, easy to miss: `url:` in `_config.yml` must be your real
domain. Every tag above is absolute, and a wrong `url:` produces a site that
looks perfect in a browser and is invisible in a search index.

> This post has no Italian translation on purpose. Open it under `/it/` and the
> banner above it is `page.missing_languages` doing its job.

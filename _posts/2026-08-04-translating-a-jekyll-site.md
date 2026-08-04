---
layout: post
lang: en
page_id: translating-a-jekyll-site
title: Translating a Jekyll site without touching a template
description: Where the strings live, why they are not in the layouts, and what the CLI actually writes.
---

A Jekyll layout that contains the sentence "Read more" has quietly made a
decision: from now on, changing that sentence is a code change. It needs a
developer, a branch and a review — for two words that a translator could have
fixed in ten seconds.

This site takes those two words out of the layout. `_layouts/blog.html` asks
for `site.data.strings.blog_read_more`, and the value comes from
`_data/en/strings.json`, `_data/es/strings.json` or `_data/it/strings.json`
depending on which language Jekyll is building at that moment.

## The dictionaries are generated, not hand-written

Nobody edits those JSON files. `multilocale download` writes them from the
project on multilocale.com, sorted, with one key per line:

```bash
npx multilocale@latest download
```

They are committed anyway. A clone of this repository builds with no account,
no network and no credentials — the sync step is how the files change, not how
they arrive.

## Missing keys fall back, they do not break

`jekyll-polyglot` merges the default-language dictionary underneath the active
one before rendering. Add a key to English, forget to translate it, and the
Italian build shows the English string rather than an empty element. The site
is never broken by an incomplete translation; it is only less translated.

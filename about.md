---
layout: page
permalink: /about/
lang: en
page_id: about
title: About this example
description: What this repository demonstrates and what it deliberately leaves out.
---

This repository is a working Jekyll site in three languages. It exists to show
one thing end to end: how translated **files** get into a static site, and who
is allowed to edit them.

Two mechanisms share the work, and the split is the whole point.

Short strings — navigation, buttons, error pages, anything that is chrome
rather than content — live in `_data/en/strings.json` and its siblings, and are
written by `multilocale download`. A translator never opens a template to fix
them, and a developer never opens a dictionary to change a layout.

Long-form content — this page, and the blog posts — lives in one Markdown file
per language, linked to its siblings by a shared `page_id`. Prose has its own
structure, its own links and its own length; forcing it through a key-value
dictionary makes it worse in every language.

The site itself is deliberately plain: no theme gem, one stylesheet, four
layouts. Everything you would have to change to make this your own site is in
files you can read in one sitting.

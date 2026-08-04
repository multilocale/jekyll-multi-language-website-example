---
layout: post
lang: es
page_id: translating-a-jekyll-site
title: Traducir un sitio Jekyll sin tocar una plantilla
description: Dónde viven los textos, por qué no están en las plantillas y qué escribe realmente la CLI.
---

Una plantilla de Jekyll que contiene la frase «Leer más» ha tomado una decisión
silenciosa: a partir de ahora, cambiar esa frase es un cambio de código.
Requiere a alguien que programe, una rama y una revisión, para dos palabras que
quien traduce podría haber corregido en diez segundos.

Este sitio saca esas dos palabras de la plantilla. `_layouts/blog.html` pide
`site.data.strings.blog_read_more`, y el valor sale de `_data/en/strings.json`,
`_data/es/strings.json` o `_data/it/strings.json` según el idioma que Jekyll
esté generando en ese momento.

## Los diccionarios se generan, no se escriben a mano

Nadie edita esos archivos JSON. `multilocale download` los escribe a partir del
proyecto en multilocale.com, ordenados y con una clave por línea:

```bash
npx multilocale@latest download
```

Aun así se suben al repositorio. Al clonar este repositorio, el sitio se genera
sin cuenta, sin red y sin credenciales: la sincronización es la forma en que
los archivos cambian, no la forma en que llegan.

## Las claves que faltan recurren al idioma predeterminado

`jekyll-polyglot` fusiona el diccionario del idioma predeterminado por debajo
del idioma activo antes de renderizar. Añade una clave en inglés, olvídate de
traducirla, y la versión italiana mostrará el texto en inglés en lugar de un
elemento vacío. Una traducción incompleta nunca rompe el sitio; simplemente lo
deja menos traducido.

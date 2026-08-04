---
layout: post
lang: es
page_id: hreflang-for-static-sites
title: Las tres etiquetas que un sitio estático multilingüe debe acertar
description: canonical, hreflang y x-default, y el sitemap que los une.
---

Una página traducida que los buscadores no pueden relacionar con sus
equivalentes acaba compitiendo con ellas. Tres etiquetas lo evitan: un
`rel="canonical"` que apunta a la URL del idioma actual, un
`rel="alternate" hreflang="…"` por cada traducción y un `hreflang="x-default"`
que apunta al idioma predeterminado. Las tres salen de `_includes/head.html`,
que lee el permalink real de cada traducción desde `page.permalink_lang`, así
que la alternativa en español sigue siendo correcta aunque su slug no comparta
ni una letra con el inglés.

`jekyll-polyglot` incluye una etiqueta que hace casi lo mismo, `i18n_headers`,
y este sitio no la usa a propósito. Solo genera una alternativa para los
idiomas que tienen su propio archivo de origen. Eso es correcto para las
páginas cuya prosa está traducida, y equivocado para todas aquellas cuyos
textos vienen de un diccionario: la portada, el índice del blog y la página 404
comparten un único archivo entre los tres idiomas, así que la etiqueta las
habría declarado solo en inglés mientras sus copias en `/es/` e `/it/` estaban
en el directorio de salida.

`sitemap.xml` dice lo mismo de otra manera: cada URL aparece una vez, con
alternativas `xhtml:link` que nombran sus traducciones. Se genera solo en el
pase del idioma predeterminado — `robots.txt` y `sitemap.xml` están en
`exclude_from_localization`, porque un sitemap que existe tres veces bajo tres
prefijos es peor que no tener ninguno.

Un requisito fácil de pasar por alto: `url:` en `_config.yml` tiene que ser tu
dominio real. Todas las etiquetas anteriores son absolutas, y un `url:`
incorrecto produce un sitio que se ve perfecto en el navegador y es invisible
en el índice de un buscador.

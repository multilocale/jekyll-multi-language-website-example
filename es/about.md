---
layout: page
permalink: /about/
lang: es
page_id: about
title: Acerca de este ejemplo
description: Qué demuestra este repositorio y qué deja fuera a propósito.
---

Este repositorio es un sitio Jekyll funcional en tres idiomas. Existe para
mostrar una sola cosa de principio a fin: cómo llegan los **archivos**
traducidos a un sitio estático y quién puede editarlos.

El trabajo se reparte entre dos mecanismos, y esa separación es justamente lo
importante.

Los textos cortos —navegación, botones, páginas de error, todo lo que es
interfaz y no contenido— viven en `_data/es/strings.json` y sus equivalentes, y
los escribe `multilocale download`. Quien traduce nunca abre una plantilla para
corregirlos, y quien programa nunca abre un diccionario para cambiar un diseño.

El contenido largo —esta página y las entradas del blog— vive en un archivo
Markdown por idioma, enlazado con sus equivalentes mediante un `page_id`
compartido. La prosa tiene su propia estructura, sus propios enlaces y su
propia extensión; meterla a la fuerza en un diccionario de clave y valor la
empeora en todos los idiomas.

El sitio en sí es deliberadamente sencillo: sin gema de tema, una sola hoja de
estilos, cuatro plantillas. Todo lo que tendrías que cambiar para hacerlo tuyo
está en archivos que puedes leer de una sentada.

---
layout: post
lang: it
page_id: translating-a-jekyll-site
title: Tradurre un sito Jekyll senza toccare un template
description: Dove vivono i testi, perché non stanno nei layout e che cosa scrive davvero la CLI.
---

Un layout Jekyll che contiene la frase «Continua a leggere» ha preso una
decisione silenziosa: da quel momento, cambiare quella frase è una modifica al
codice. Servono chi programma, un branch e una revisione, per tre parole che
chi traduce avrebbe corretto in dieci secondi.

Questo sito toglie quelle parole dal layout. `_layouts/blog.html` chiede
`site.data.strings.blog_read_more`, e il valore arriva da
`_data/en/strings.json`, `_data/es/strings.json` o `_data/it/strings.json` a
seconda della lingua che Jekyll sta generando in quel momento.

## I dizionari sono generati, non scritti a mano

Quei file JSON non li modifica nessuno. `multilocale download` li scrive a
partire dal progetto su multilocale.com, ordinati e con una chiave per riga:

```bash
npx multilocale@latest download
```

Vengono comunque committati. Chi clona questo repository genera il sito senza
account, senza rete e senza credenziali: la sincronizzazione è il modo in cui i
file cambiano, non il modo in cui arrivano.

## Le chiavi mancanti ricadono sulla lingua predefinita

`jekyll-polyglot` unisce il dizionario della lingua predefinita sotto quello
della lingua attiva prima di renderizzare. Aggiungi una chiave in inglese,
dimenticati di tradurla, e la versione italiana mostrerà il testo inglese
invece di un elemento vuoto. Una traduzione incompleta non rompe mai il sito:
lo lascia soltanto meno tradotto.

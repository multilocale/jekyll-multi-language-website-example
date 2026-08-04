---
layout: page
permalink: /about/
lang: it
page_id: about
title: Informazioni su questo esempio
description: Che cosa dimostra questo repository e che cosa lascia fuori di proposito.
---

Questo repository è un sito Jekyll funzionante in tre lingue. Esiste per
mostrare una cosa sola, dall'inizio alla fine: come i **file** tradotti
arrivano in un sito statico e chi può modificarli.

Il lavoro è diviso tra due meccanismi, e proprio quella divisione è il punto.

I testi brevi — navigazione, pulsanti, pagine di errore, tutto ciò che è
interfaccia e non contenuto — vivono in `_data/it/strings.json` e nei file
corrispondenti, e li scrive `multilocale download`. Chi traduce non apre mai un
template per correggerli, e chi programma non apre mai un dizionario per
cambiare un layout.

I contenuti lunghi — questa pagina e gli articoli del blog — vivono in un file
Markdown per lingua, collegato ai suoi equivalenti da un `page_id` condiviso.
La prosa ha una sua struttura, dei suoi link e una sua lunghezza; costringerla
dentro un dizionario chiave-valore la peggiora in tutte le lingue.

Il sito in sé è volutamente essenziale: nessuna gemma per il tema, un solo
foglio di stile, quattro layout. Tutto ciò che dovresti cambiare per farlo tuo
sta in file che puoi leggere in una volta sola.

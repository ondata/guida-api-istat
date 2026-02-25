<p class="float-right"><a href="./">Apri la guida principale</a></p>

# Ricette pratiche

Questa pagina raccoglie ricette operative basate sulle API ISTAT, con esempi replicabili da terminale.

Abbiamo ricevuto alcune ricette dalla community e ci fa piacere inserirle qui.
Se vuoi proporne una anche tu, apri una issue: <https://github.com/ondata/guida-api-istat/issues/new>.

## Ricette disponibili

| Ricetta | Cosa fa | Strumenti |
| --- | --- | --- |
| [Popolazione residente - regioni](./ricette/pop_res_regioni.md) | Estrae serie popolazione per regioni (NUTS2) | curl, VisiData |
| [Popolazione residente - province](./ricette/pop_res_province.md) | Estrae serie popolazione per province (NUTS3) | curl, DuckDB |
| [Popolazione residente - comuni (focus Sicilia)](./ricette/pop_res_comuni_sicilia.md) | Estrae i comuni e mostra filtro operativo per Sicilia | curl, VisiData |

## Note utili

- Le ricette usano endpoint `https://esploradati.istat.it/SDMXWS/rest`.
- Per il bug temporale noto: su `endPeriod` applicare il workaround descritto in [note-endpoint-esploradati.md](./processing/note-endpoint-esploradati.md).
- In caso di download pesanti, usare sempre filtri e limiti (`firstNObservations`, `lastNObservations`) quando possibile.

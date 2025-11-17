# Changelog

## 2025-11-17

### Aggiornamento guida con specifiche OpenAPI v2.0.0

**Documentazione:**

- Aggiunta sezione "Specifiche OpenAPI ufficiali" con link spec YAML Team Digitale
- Documentato endpoint v2.0.0: `https://esploradati.istat.it/SDMXWS/rest`
- Aggiunta sezione SEP (Single Exit Point) con caratteristiche
- Aggiunta nota implementazione: parametro `format` non supportato, solo header `Accept`

**Parametri query espansi:**

- Metadati: detail (allstubs, referencepartial, ecc.), references (none, parents, children, descendants)
- Dati: flowRef (formati), key (wildcarding .. e +)
- Filtri temporali: startPeriod, endPeriod (ISO 8601 + SDMX Q1, W01, S1)
- Limitazione: firstNObservations, lastNObservations
- Formato: dimensionAtObservation, detail (full, dataonly, serieskeysonly, nodata)
- Storico: includeHistory

**Nuovi endpoint:**

- Documentato availableconstraint (verificare disponibilità dati)

**Codici HTTP:**

- Documentati codici successo (200, 304) ed errori (400, 406, 413, 414, 500, 503)
- Aggiunte best practice

**Esempi pratici:**

- Filtrare per periodo temporale (ISO 8601 e SDMX)
- Limitare numero osservazioni (firstN, lastN)
- Ottenere solo chiavi serie (serieskeysonly)
- Selezione formato con header Accept

**Script:**

- Aggiornato endpoint in apiRestISTAT.sh (2 occorrenze)
- Aggiornato endpoint in script/aggiornamenti.sh
- Aggiornato endpoint in script/aggiornamenti_next.sh
- jiku_istat.sh già aggiornato

**Sitografia:**

- Aggiunto link spec OpenAPI in testa
- Riorganizzata in sezioni (ISTAT/Standard SDMX)

**File aggiunti:**

- docs/istat-openapi.yaml (spec ufficiale, 745 righe)

# Changelog

## 2026-01-08

### HVD/OpenAPI: aggiornamento riferimenti e esempi

**README:**

- Aggiunta risorsa OpenAPI HVD (`https://esploradati.istat.it/HVD/swagger/v2/sdmx-rest.yaml`)
- Inserita sezione esempi HVD (SDMX 3.0 / OpenAPI)
- Nota su parametri disponibili (no startPeriod/endPeriod in HVD)

**Note endpoint:**

- Aggiornata nota `processing/note-endpoint-esploradati.md` con link HVD e data (gennaio 2026)

**Test eseguiti:**

- `https://esploradati.istat.it/HVD/rest/v2` (HEAD) → 405 (Allow: GET)
- `https://esploradati.istat.it/HVD/rest/v2/structure/dataflow/IT1/41_983/1.0` → 404
- `https://esploradati.istat.it/HVD/rest/v2/data/dataflow/IT1/41_983/1.0/*` → 404

## 2025-11-17 (sera - parte 2)

### Aggiunta sezione Quick Start

**Obiettivo UX:** Permettere a nuovo utente di testare API in 5 minuti

**Contenuto Quick Start (righe 36-123):**

- 3 esempi pratici copy-paste pronti all'uso:
  1. Primo dato ISTAT (ultimi 5 record incidenti, CSV)
  2. Elenco tutti dataset disponibili (dataflow)
  3. Dati specifici filtrati (Palermo, feriti, 10 anni)
- Output esempio per ogni comando
- Spiegazione "Cosa hai fatto" dopo ogni esempio
- Link navigazione "Prossimi passi" a sezioni approfondimento
- Consiglio best practice su uso `firstNObservations`/`lastNObservations`

**Modifiche struttura:**

- TOC: aggiunta voce "🚀 Quick Start (5 minuti)" in prima posizione
- Posizionamento: subito dopo TOC, prima di "Perché questa guida"
- Emoji 🚀 per visibilità immediata

**Test eseguiti:**

- ✅ Esempio 1: restituisce CSV con ultimi 5 record
- ✅ Esempio 2: restituisce XML dataflow list
- ✅ Esempio 3: restituisce CSV filtrato Palermo feriti 10 anni

**Impatto UX:** Utente può vedere API funzionanti immediatamente senza leggere teoria

**File documentazione:**

- `docs/suggerimenti-ux-readme.md`: analisi completa UX con altri suggerimenti

## 2025-11-17 (sera - parte 1)

### Test e correzioni README

**Test endpoint eseguiti:**

- ✅ Endpoint metadati (dataflow) - funzionante
- ✅ Formato CSV per dati - funzionante
- ✅ Formato JSON per dati (`application/json`) - funzionante
- ✅ Formato JSON per metadati (`application/vnd.sdmx.structure+json`) - funzionante
- ✅ Parametri `firstNObservations` / `lastNObservations` - funzionanti
- ✅ Filtri dimensionali con chiavi - funzionanti
- ✅ Operatore OR con `+` - funzionante
- ❌ **Bug critico confermato**: `endPeriod` restituisce sempre anno+1

**Correzioni applicate README:**

- Sezione "Situazione endpoint": descrizione dettagliata bug `endPeriod` con esempi pratici
- Sezione "Filtrare per periodo temporale": aggiunto avviso prominente sul bug
- Cheatsheet: aggiunto warning su parametro `endPeriod` nella tabella
- Cheatsheet: corretta colonna formati con indicazione formati testati ✅
- Cheatsheet: aggiunta nota su selezione formato solo via header `Accept`

**File creati:**

- `processing/test-report-2025-11-17.md`: report completo test con metodologia e risultati

**Raccomandazione workaround bug:** Per dati fino anno N usare `endPeriod=N-1`

## 2025-11-17 (mattina)

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

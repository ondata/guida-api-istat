# Changelog - Aggiunta Sezione Troubleshooting

**Data**: 2026-01-08  
**Commit**: Aggiunta sezione 🔧 Troubleshooting al README

## Modifiche apportate

### 1. Nuova sezione Troubleshooting

Aggiunta sezione completa con 8 problemi comuni e relative soluzioni:

#### Errori HTTP
- **413 Request Entity Too Large**: Soluzioni con filtri temporali, limitazione osservazioni, filtri dimensionali
- **414 URI Too Long**: Strategie per ridurre lunghezza URL con query multiple
- **400 Bad Request**: Diagnosi errori sintassi (ordine dimensioni, codici non validi, formato periodo)
- **406 Not Acceptable**: Guida ai formati supportati con esempi header `Accept`

#### Problemi operativi
- **Timeout/lentezza**: Best practice per test con limiti, uso di `serieskeysonly`, applicazione filtri
- **Dati vuoti**: Diagnosi con `availableconstraint` e verifica filtri
- **Errore SSL/certificato**: Uso opzione `-k` per test
- **Bug endPeriod (+1 anno)**: Workaround documentato per bug noto

#### Supporto
- **Come ottenere aiuto**: Link a suite test, issue GitHub, documentazione SDMX

### 2. Aggiornamento TOC

Aggiunto link alla nuova sezione Troubleshooting con sottosezioni:
```markdown
- [🔧 Troubleshooting](#-troubleshooting)
  - [Errore 413 (Request Entity Too Large)](#errore-413-request-entity-too-large)
  - [Errore 414 (URI Too Long)](#errore-414-uri-too-long)
  - ...
```

### 3. Script di validazione

Creato script `validate_troubleshooting.sh` per verificare:
- Presenza sezione e sottosezioni
- Completezza della documentazione
- Link nel TOC funzionanti

## Statistiche

- **Righe aggiunte**: 249
- **Problemi documentati**: 8
- **Esempi di codice**: 30+ nuovi snippet bash
- **Link nuovi nel TOC**: 10

## Test eseguiti

✅ **Suite test README** (16/16 test superati)
- Quick Start examples
- Metadati endpoints
- Formati output
- Filtri temporali
- Parametri limitazione
- Filtri dimensionali

✅ **Validazione Troubleshooting** (9/9 controlli superati)
- Presenza tutte le sottosezioni
- Link nel TOC corretto
- Esempi di codice presenti

## File modificati

```
README.md                                 | +249 linee
script/test_readme_examples.sh           | nuovo file
script/validate_troubleshooting.sh       | nuovo file
docs/suggerimenti_miglioramento.md       | nuovo file
```

## Prossimi passi suggeriti

1. ✅ **Completato**: Troubleshooting section
2. 🔄 **Opzionale**: Aggiungere casi d'uso reali (vedi `docs/suggerimenti_miglioramento.md`)
3. 🔄 **Opzionale**: Snippet Python/R per utenti non-bash
4. 🔄 **Opzionale**: Flowchart decisionale per costruzione query

## Note implementazione

- Tutti gli esempi sono stati testati e verificati funzionanti
- La sezione mantiene lo stile del resto del documento (emoji, formattazione, esempi)
- Ogni problema include: sintomo → causa → soluzione con esempi pratici
- Collegamenti interni al documento per approfondimenti (es. bug `endPeriod`)

# Script di Test per la Guida API ISTAT

Questo script testa automaticamente tutti gli esempi presenti nel README della guida.

## Utilizzo

```bash
./script/test_readme_examples.sh
```

## Cosa testa

Lo script esegue **16 test** che validano:

### Quick Start Examples (3 test)
- ✅ Primi 5 record incidenti in CSV
- ✅ Lista dataflow XML completa
- ✅ Feriti Palermo ultimi 10 record

### Metadati (4 test)
- ✅ Endpoint dataflow (lista dataset IT1)
- ✅ Datastructure DCIS_INCIDMORFER_COM
- ✅ Codelist CL_FREQ (frequenze)
- ✅ Availableconstraint dataset 41_983

### Formati Output (3 test)
- ✅ Formato CSV con header Accept
- ✅ Formato JSON semplificato
- ✅ Formato JSON strutture (metadati)

### Filtri Temporali (1 test)
- ✅ startPeriod e endPeriod

### Parametri Limitazione (3 test)
- ✅ firstNObservations=10
- ✅ lastNObservations=5
- ✅ detail=serieskeysonly

### Filtri Dimensionali (2 test)
- ✅ Filtro singolo (Palermo feriti)
- ✅ Filtro OR multiplo (Palermo+Bari)

## Output

Lo script produce output colorato con:
- 🟢 **Verde** per test superati
- 🔴 **Rosso** per test falliti
- 🟡 **Giallo** per le sezioni

**Precheck di connettività**:
Prima di eseguire i test, lo script verifica che il server ISTAT sia raggiungibile:
```
[PRECHECK] Verificando raggiungibilità server ISTAT...
✓ Server ISTAT raggiungibile
```

Se il server non è disponibile, esce immediatamente con un messaggio chiaro.

**Esempio output**:
```
==========================================
TEST SUITE README.md - API ISTAT
==========================================

=== QUICK START EXAMPLES ===

[TEST 1] Esempio 1: Primi 5 record incidenti (CSV)
✓ PASSED

[TEST 2] Esempio 2: Lista dataflow XML
✓ PASSED

...

==========================================
RISULTATI TEST
==========================================
Totale test:   16
Superati:      16
Falliti:       0

✓ TUTTI I TEST SUPERATI
```

## Durata

I test completano in circa **2-3 minuti** (dipende dalla velocità della connessione).

## File di output

I risultati vengono salvati in `./tmp/readme_tests/`:
- `test_1.output`, `test_2.output`, ..., `test_16.output`

Ogni file contiene l'output della chiamata API corrispondente, utile per debug in caso di fallimento.

## Requisiti

- `bash` (4.0+)
- `curl`
- Connessione internet attiva
- Accesso a `https://esploradati.istat.it`

## Quando usarlo

### Per sviluppatori
- ✅ Prima di commit modifiche al README
- ✅ Per validare che gli esempi funzionino
- ✅ Per verificare breaking changes nelle API ISTAT

### Per utenti
- 🔍 Per verificare che le API ISTAT siano online
- 🐛 Per diagnosticare problemi di connessione
- 📚 Per vedere esempi concreti di chiamate funzionanti

## Exit codes

- `0`: Tutti i test superati
- `1`: Uno o più test falliti

## Esempio integrazione CI/CD

```yaml
# .github/workflows/test.yml
name: Test API Examples

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Test README examples
        run: ./script/test_readme_examples.sh
```

## Troubleshooting

**Problema**: Test falliscono con timeout  
**Soluzione**: Aumenta il timeout nella funzione `test_endpoint` dello script (da 45s a 90s se connessione lenta)

**Problema**: Errori SSL  
**Soluzione**: Lo script usa già `-k` per ignorare certificati

**Problema**: Server ISTAT non raggiungibile  
**Soluzione**: Lo script verifica automaticamente la connettività prima dei test. Se esce con errore:
- Verifica connessione internet: `ping 8.8.8.8`
- Testa manualmente: `curl -I https://esploradati.istat.it`
- Attendi qualche minuto (possibile manutenzione)
- Controlla <https://www.istat.it> per comunicazioni ufficiali

## File correlati

- `script/validate_troubleshooting.sh` - Valida completezza sezione Troubleshooting
- `docs/suggerimenti_miglioramento.md` - Ulteriori suggerimenti per la guida
- `docs/CHANGELOG_troubleshooting.md` - Changelog modifiche recenti

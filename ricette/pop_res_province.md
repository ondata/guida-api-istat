# Popolazione Residente Province ISTAT

## Introduzione

Ricetta per scaricare i dati sulla popolazione residente per province (livello NUTS3).

Le province sono identificate da codici NUTS3 di 5 caratteri (es. ITC11 = Torino, ITG28 = Ragusa).

## Cosa serve

1. Shell Linux
2. Curl
3. DuckDB (opzionale, per filtrare i dati)

## Nota endpoint

Questa ricetta usa l'endpoint ufficiale `https://esploradati.istat.it/SDMXWS/rest` con workaround per bug filtri temporali.

**Bug ISTAT**: per anno N usare `endperiod=N-1`

Dettagli: [../processing/note-endpoint-esploradati.md](../processing/note-endpoint-esploradati.md)

## Scarica dati grezzi

```bash
# ATTENZIONE: bug ISTAT - per 2024 usare endperiod=2023
curl -kL -H "Accept: text/csv" \
  "https://esploradati.istat.it/SDMXWS/rest/data/IT1,22_289/A..JAN.9.TOTAL.99/?startperiod=2023&endperiod=2023" \
  >pop_tutti_territori.csv
```

**Nota**: il comando richiede circa 2 minuti per completare.

**Parametri query:**

- `.TOTAL` = totale maschi+femmine
- `..` = tutti i territori (Italia, ripartizioni, regioni, province, comuni)
- `.9.99` = tutti gli stati civili, tutte le età
- `..` = dati a gennaio (popolazione fine anno precedente)
- `startPeriod=2023&endPeriod=2024` = anni 2023 e 2024

## Estrai solo province con DuckDB

```bash
duckdb -c "COPY (
  SELECT
    ITTER107 as codice_provincia,
    TIME_PERIOD as anno,
    OBS_VALUE as popolazione
  FROM 'pop_tutti_territori.csv'
  WHERE LENGTH(ITTER107) = 5
    AND REGEXP_MATCHES(ITTER107, '^IT[A-Z][0-9]')
  ORDER BY ITTER107, TIME_PERIOD
) TO 'popolazione_province.csv' (HEADER, DELIMITER ',')"
```

**Filtro:**

- `LENGTH(ITTER107) = 5` = codici con 5 caratteri
- `REGEXP_MATCHES(ITTER107, '^IT[A-Z][0-9]')` = codici NUTS3 (IT + lettera + numero)

## Output

CSV pulito con 3 colonne:

- `codice_provincia`: codice NUTS3 (es. ITC11, ITG28)
- `anno`: anno di riferimento
- `popolazione`: numero abitanti

## Riferimenti utili

- [Curl](https://curl.se/)
- [DuckDB](https://duckdb.org/)
- [Codici NUTS Italia](https://it.wikipedia.org/wiki/Nomenclatura_delle_unit%C3%A0_territoriali_statistiche)

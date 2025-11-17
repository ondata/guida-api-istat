# Note endpoint esploradati.istat.it

## Situazione attuale (novembre 2025)

### Endpoint disponibili

**Endpoint ufficiale nuovo:**
- `https://esploradati.istat.it/SDMXWS/rest`

**Endpoint legacy (vecchio):**
- `http://sdmx.istat.it/SDMXWS/rest`

### Problemi riscontrati

#### 1. Endpoint `/rest/v2/data` non attivo

La documentazione OpenAPI (`https://esploradati.istat.it/SDMXWS/swagger/v2/sdmx-rest.yaml`) documenta l'endpoint `/rest/v2/data`, ma **non è ancora implementato**.

Query come questa **non funzionano**:

```bash
curl -kL -H "Accept: text/csv" \
"https://esploradati.istat.it/SDMXWS/rest/v2/data/dataflow/IT1/22_289/1.0/A.*.JAN.9.TOTAL.99?c%5BTIME_PERIOD%5D=eq:2023"
```

Restituisce righe senza valori in `OBS_VALUE`.

#### 2. Bug filtro temporale su `/rest/data`

L'endpoint `/rest/data` funziona ma ha un **bug confermato da ISTAT**:

Per ottenere dati 2023 bisogna usare `endperiod=2022` (workaround temporaneo):

```bash
# BUG: per avere 2023 devi mettere endperiod=2022
curl -kL -H "Accept: text/csv" \
  "https://esploradati.istat.it/SDMXWS/rest/data/IT1,22_289/A..JAN.9.TOTAL.99/?startperiod=2023&endperiod=2022"
```

Query corretta (che non funziona):

```bash
# NON FUNZIONA (restituisce dati vuoti)
curl -kL -H "Accept: text/csv" \
  "https://esploradati.istat.it/SDMXWS/rest/data/IT1,22_289/A..JAN.9.TOTAL.99/?startperiod=2023&endperiod=2023"
```

#### 3. Performance

L'endpoint `esploradati` è **molto lento**:
- Query che su `sdmx.istat.it` impiegano 5 secondi
- Su `esploradati.istat.it` impiegano oltre 2 minuti

### Raccomandazione attuale

**Usare endpoint legacy fino a risoluzione problemi:**

```bash
curl -kL -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" \
  "http://sdmx.istat.it/SDMXWS/rest/data/22_289/.TOTAL..9.99../?startPeriod=2023&endPeriod=2024"
```

**Vantaggi endpoint legacy:**
- ✅ Filtri temporali funzionano correttamente
- ✅ Veloce (5-10 secondi vs 2+ minuti)
- ✅ Stabile e testato

### Risposta ISTAT Contact Centre

> il problema è nostro e ce ne scusiamo: in effetti la pagina del webservice riporta (anticipatamente rispetto alla versione webservice necessaria) anche l'endpoint https://esploradati.istat.it/SDMXWS/rest/v2 che lei sta provando ad utilizzare, ma attualmente il medesimo webservice è però ad una versione che, ancora, non supporta tale endpoint, che quindi in effetti ad oggi non è utilizzabile.
>
> Di nuovo si sottolinea che mettere il parametro endperiod un anno indietro (2022 invece che 2023) è, appunto, una soluzione provvisoria ad un'anomalia che speriamo di risolvere in futuro.
>
> _Silvio Vitale - Istat Contact Centre (novembre 2025)_

### Timeline

- **2024**: pubblicazione specifiche OpenAPI v3 con endpoint `esploradati.istat.it`
- **Novembre 2025**: endpoint `/v2` non attivo, bug su filtri temporali `/rest/data`
- **Situazione**: endpoint legacy rimane l'unica soluzione affidabile

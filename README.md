- [Guida all'uso delle API REST di ISTAT](#guida-alluso-delle-api-rest-di-istat)
  - [Perché questa guida](#perché-questa-guida)
  - [Come interrogarle](#come-interrogarle)
    - [Che strumenti usare](#che-strumenti-usare)
    - [Accedere ai metadati](#accedere-ai-metadati)
    - [Accedere ai dati](#accedere-ai-dati)
  - [Qualche esempio](#qualche-esempio)
    - [Scaricare i dati in blocco](#scaricare-i-dati-in-blocco)
    - [Cambiare formato di output](#cambiare-formato-di-output)
    - [Applicare dei filtri](#applicare-dei-filtri)
- [Note](#note)
- [Sitografia](#sitografia)

# Guida all'uso delle API REST di ISTAT

## Perché questa guida

L'**Istituto nazionale di statistica** (ISTAT) consente di accedere ai dati del proprio *warehouse* ([http://dati.istat.it/](http://dati.istat.it/)) in molte modalità. L'accesso via ***API REST*** è poco noto, molto comodo, ma **poco documentato**.<br>
Nella [pagina](https://www.istat.it/it/metodi-e-strumenti/web-service-sdmx) ufficiale dei loro *web service* e nelle guide presenti non c'è alcuna documentazione dedicata.<br>
C'è un riferimento alle "*RESTful API*" in questa pagina http://sdmx.istat.it/SDMXWS/.

La mancanza di informazioni in merito e le opportunità che vengono offerte, ci hanno spinto a scrivere questa guida non esaustiva, che descrive queste modalità di accesso.

## Come interrogarle

L'URL base di accesso è `http://sdmx.istat.it/SDMXWS/rest/`. Da questo si possono interrogare i **metadati** e i **dati**, con una chiamata `HTTP` in `GET`. Quindi pressoché **da qualsiasi client**, **senza installare nulla**.

Sono dati esposti secondo lo standard **SDMX**.

### Che strumenti usare

Vista la modalità di accesso, basta un *browser*, `wget`, `cURL` e/o qualsiasi modulo/funzione che in un linguaggio di scripting consenta l'accesso `HTTP` in `GET`.

### Accedere ai metadati

Questa è la struttura dell'URL per accedere ai **metadati**:

```
http://sdmx.istat.it/SDMXWS/rest/resource/agencyID/resourceID/version/itemID?queryStringParameters
```

Alcune note:

- `resource` (**obbligatorio**), la risorsa che si vuole interrogare (tra queste `categorisation`, `categoryscheme`, `codelist`, `conceptscheme`, `contentconstraint`, `dataflow` e `datastructure`);
- `agencyID`, l'identiticativo dell'agenzia che esponi i dati (qui è `IT1`);
- `resourceID`, l'ID della risorsa che si vuole interrogare (successivamente qualche esempio);
- `version`, la versione dell'artefatto che si vuole interrogare;
- `itemID`, l'ID dell'elemento (per schemi di elementi) o della gerarchia (per elenchi di codici gerarchici) da restituire;
- `queryStringParameters`
  - `detail`, la quantità desiderata di informazioni. I valori possibili sono `allstubs`, `referencestubs`, `allcompletestubs`, `referencecompletestubs`, `referencepartial` e `full` e di *default* è `full`.
di riferimento parziale, completo.
  - `references`, riferimenti relativi da restituire. I valori possibili sono  `none`, `parents`,  `parentsandsiblings`, `children`, `descendants`, `all`, `any` e di *default* è `none`.


Un esempio è quello che restituisce i **`dataflow`**, ovvero l'elenco dei flussi di dati interrogabili.<br>Per averlo restituito l'URL è http://sdmx.istat.it/SDMXWS/rest/dataflow/IT1

Si ottiene in risposta un file XML come [questo](rawdata/dataflow.xml), che all'interno contiene dei blocchi come quello sottostante, in cui ai dati su "Incidenti, morti e feriti - comuni" è associato l'id `41_983`.

```xml
<structure:Dataflow id="41_983" urn="urn:sdmx:org.sdmx.infomodel.datastructure.Dataflow=IT1:41_983(1.0)" agencyID="IT1" version="1.0" isFinal="false">
  <common:Name xml:lang="it">Incidenti, morti e feriti - comuni</common:Name>
  <common:Name xml:lang="en">Road accidents, killed and injured - municipalities</common:Name>
  <structure:Structure>
    <Ref id="DCIS_INCIDMORFER_COM" version="1.0" agencyID="IT1" package="datastructure" class="DataStructure" />
  </structure:Structure>
</structure:Dataflow>
```

L'elenco ad oggi (3 maggio 2020) dei dataset interrogabili è composto da circa 450 elementi, visualizzabili in [questo file CSV](processing/dataflow.csv).

### Accedere ai dati

Questa è la struttura dell'URL per accedere ai **dati**:

```
http://sdmx.istat.it/SDMXWS/rest/data/flowRef/key/providerRef?queryStringParameters
```

Alcune note:

- `flowRef` (**obbligatorio**), l'ID del `dataflow` che si vuole interrogare;
- `key`, i parametri che si vogliono aggiungere per personalizzare la *query* (ad esempio soltanto gli incidenti avvenuti nel comune di Bari e Palermo);
- `providerRef`, l'identiticativo dell'agenzia che esponi i dati (qui è `IT1`);
- `queryStringParameters`, sono quelli sottostanti. In questa prima release ne descriviamo soltanto alcuni.
  - `startPeriod`, la data da cui iniziare a estrarre informazioni, in formato `ISO8601` (ad esempio ` 2014-01`, ` 2014-01-01`, ecc.) o in formato SDMX (`2014-Q3` per il terzo quarto del 2014 o `2014-W53` per la cinquantatreesima settimana);
  - `endPeriod`, come sopra ma la data di fine intervallo;
  - `updatedAfter`;
  - `firstNObservations`;
  - `lastNObservations`;
  - `dimensionAtObservation`;
  - `detail`;
  - `includeHistory`.

Visto che l'unico parametro obbligatorio è l'ID del *dataflow*, per scaricare quello di sopra sugli incidenti stradali l'URL sarà (**OCCHIO CHE SUL BROWSER pesa**, sono 53 MB di file XML, meglio non fare click e leggerlo soltanto) http://sdmx.istat.it/SDMXWS/rest/data/41_983

## Qualche esempio

Per gli esempi sottostanti verrà usata l'*utility* cURL, in quanto disponibile e utilizzabile su qualsiasi sistema operativo.

**NOTA BENE**: scaricando i file in blocco, senza alcun filtro, si ottengono file di **grandi dimensioni**. Pertanto - ove possibile - è consigliato applicare i filtri adeguati ai propri interessi, sia per non avere informazioni ridondanti, che per non stressare il servizio di ISTAT.

### Scaricare i dati in blocco

Il formato di output di default è l'XML.

```bash
curl -kL "http://sdmx.istat.it/SDMXWS/rest/data/41_983" >./41_983.xml
```

### Cambiare formato di output

Basta impostare in modo adeguato l'header `HTTP`.

In CSV:

```bash
curl -kL -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "http://sdmx.istat.it/SDMXWS/rest/data/41_983" >./41_983.csv
```

In JSON:

```bash
curl -kL -H "Accept: application/json" "http://sdmx.istat.it/SDMXWS/rest/data/41_983" >./41_983.json
```

### Applicare dei filtri

Per applicare dei filtri è **necessario** **conoscere** quale sia lo **schema dati** del *dataflow* che si vuole interrogare. Questo è descritto nella risorsa di metadati denominata `datastructure`, che si può interrogare per ID. Ma qual è ad esempio l'ID del *dataset* sugli incidenti stradali, presente in `datastructure`?<br>
È scritto nel *dataflow*. Si riporta nuovamente quello di sopra e si legge che l'ID di riferimento presente in *datastructure* è  `DCIS_INCIDMORFER_COM`.

```xml
<structure:Dataflow id="41_983" urn="urn:sdmx:org.sdmx.infomodel.datastructure.Dataflow=IT1:41_983(1.0)" agencyID="IT1" version="1.0" isFinal="false">
  <common:Name xml:lang="it">Incidenti, morti e feriti - comuni</common:Name>
  <common:Name xml:lang="en">Road accidents, killed and injured - municipalities</common:Name>
  <structure:Structure>
    <Ref id="DCIS_INCIDMORFER_COM" version="1.0" agencyID="IT1" package="datastructure" class="DataStructure" />
  </structure:Structure>
</structure:Dataflow>
```

Per leggere lo schema dati di `DCIS_INCIDMORFER_COM`, si potrà lanciare questa chiamata:

```bash
curl -kL "http://sdmx.istat.it/SDMXWS/rest/datastructure/IT1/DCIS_INCIDMORFER_COM/" >./DCIS_INCIDMORFER_COM.xml
```

Nel file [XML di output](esempi/DCIS_INCIDMORFER_COM.xml) c'è il tag `structure:DimensionList` (vedi sotto), che contiene la lista delle dimensioni, ovvero lo schema dati del dataset.<br>
In questo elenco le dimensioni con id `FREQ`, `ESITO`, `ITTER107`,`TIPO_DATO` e `SELECT_TIME`.

```xml
<structure:DimensionList id="DimensionDescriptor" urn="urn:sdmx:org.sdmx.infomodel.datastructure.DimensionDescriptor=IT1:DCIS_INCIDMORFER_COM(1.0).DimensionDescriptor">
  <structure:Dimension id="FREQ" urn="urn:sdmx:org.sdmx.infomodel.datastructure.Dimension=IT1:DCIS_INCIDMORFER_COM(1.0).FREQ" position="1">
    <structure:ConceptIdentity>
      <Ref id="FREQ" maintainableParentID="CROSS_DOMAIN" maintainableParentVersion="4.2" agencyID="IT1" package="conceptscheme" class="Concept" />
    </structure:ConceptIdentity>
    <structure:LocalRepresentation>
      <structure:Enumeration>
        <Ref id="CL_FREQ" version="1.0" agencyID="IT1" package="codelist" class="Codelist" />
      </structure:Enumeration>
    </structure:LocalRepresentation>
  </structure:Dimension>
  <structure:Dimension id="ESITO" urn="urn:sdmx:org.sdmx.infomodel.datastructure.Dimension=IT1:DCIS_INCIDMORFER_COM(1.0).ESITO" position="2">
    <structure:ConceptIdentity>
      <Ref id="ESITO" maintainableParentID="VARIAB_ALL" maintainableParentVersion="18.3" agencyID="IT1" package="conceptscheme" class="Concept" />
    </structure:ConceptIdentity>
    <structure:LocalRepresentation>
      <structure:Enumeration>
        <Ref id="CL_ESITO" version="1.0" agencyID="IT1" package="codelist" class="Codelist" />
      </structure:Enumeration>
    </structure:LocalRepresentation>
  </structure:Dimension>
  <structure:Dimension id="ITTER107" urn="urn:sdmx:org.sdmx.infomodel.datastructure.Dimension=IT1:DCIS_INCIDMORFER_COM(1.0).ITTER107" position="3">
    <structure:ConceptIdentity>
      <Ref id="ITTER107" maintainableParentID="VARIAB_ALL" maintainableParentVersion="18.3" agencyID="IT1" package="conceptscheme" class="Concept" />
    </structure:ConceptIdentity>
    <structure:LocalRepresentation>
      <structure:Enumeration>
        <Ref id="CL_ITTER107" version="4.6" agencyID="IT1" package="codelist" class="Codelist" />
      </structure:Enumeration>
    </structure:LocalRepresentation>
  </structure:Dimension>
  <structure:Dimension id="TIPO_DATO" urn="urn:sdmx:org.sdmx.infomodel.datastructure.Dimension=IT1:DCIS_INCIDMORFER_COM(1.0).TIPO_DATO" position="4">
    <structure:ConceptIdentity>
      <Ref id="TIPO_DATO" maintainableParentID="CROSS_DOMAIN" maintainableParentVersion="4.2" agencyID="IT1" package="conceptscheme" class="Concept" />
    </structure:ConceptIdentity>
    <structure:LocalRepresentation>
      <structure:Enumeration>
        <Ref id="CL_TIPO_DATO22" version="1.0" agencyID="IT1" package="codelist" class="Codelist" />
      </structure:Enumeration>
    </structure:LocalRepresentation>
  </structure:Dimension>
  <structure:TimeDimension id="TIME_PERIOD" urn="urn:sdmx:org.sdmx.infomodel.datastructure.TimeDimension=IT1:DCIS_INCIDMORFER_COM(1.0).TIME_PERIOD" position="5">
    <structure:ConceptIdentity>
      <Ref id="SELECT_TIME" maintainableParentID="CROSS_DOMAIN" maintainableParentVersion="4.2" agencyID="IT1" package="conceptscheme" class="Concept" />
    </structure:ConceptIdentity>
    <structure:LocalRepresentation>
      <structure:TextFormat textType="ObservationalTimePeriod" />
    </structure:LocalRepresentation>
  </structure:TimeDimension>
```

Ma qual è il **significato** di `FREQ`, `ESITO`, `ITTER107`,`TIPO_DATO` e `SELECT_TIME` e che **valori** sono **ammissibili**?

La risposta a queste domande ce le dà la risorsa di metadati - il *package* - denominata `codelist`. Si può interrogare sempre per ID, ma bisogna conoscere l'ID dei vari campi, che è scritto nel file XML di sopra.<br>
Ad esempio in corrispondenza del campo `FREQ` si legge `<Ref id="CL_FREQ" version="1.0" agencyID="IT1" package="codelist" class="Codelist" />`, ovvero che l'ID corrispondente in `codelist` è `CL_FREQ`. L'URL da lanciare per avere le informazioi su questo campo, sarà un altro URL per interrogare metadati e in particolare http://sdmx.istat.it/SDMXWS/rest/codelist/IT1/CL_FREQ.

In output un [file XML](esempi/CL_FREQ.xml), dove si legge che si tratta della "Frequenza", a cui si possono associare diversi valori. Per ogni valore come sempre un ID e qui anche una descrizione. Per `CL_FREQ` i valori sono:

| ID | Descrizione |
| --- | --- |
| A | annuale |
| B | business (non supportato) |
| D | giornaliero |
| E | event (non supportato) |
| H | semestrale |
| M | mensile |
| Q | trimestrale |
| W | settimanale |

Per ognuno dei campi, si possono estrarre i valori possibili nello stesso modo. Ad esempio per `ESITO` l'URL sarà http://sdmx.istat.it/SDMXWS/rest/codelist/IT1/CL_ESITO, con le coppie ID-Descrizione `M-morto`, `F-ferito` e `9-totale`.

Una ***query*** per **attributo/i**, ne deve **elencare i valori** nell'URL secondo questo schema:

```
http://sdmx.istat.it/SDMXWS/rest/data/flowRef/valoreCampo1.valoreCampo2.valoreCampo3/
```

Questo di sopra è un caso di uno schema dati con tre campi, e i valori sono separati da `.` (punto). Se il valore non è specificato, nessun filtro per quel campo sarà applicato. Quindi un URL come

```
http://sdmx.istat.it/SDMXWS/rest/data/flowRef/../
```

equivale a non applicare alcun filtro.

Un esempio potrebbe essere quello di tutti gli incidenti con feriti (**valore** `F`). Il campo è `ESITO`, che nello schema dati è il **secondo** campo. Per ottenere i dati così filtrati - filtro quindi `.F...` - si potrà pertanto lanciare:

```bash
curl -kL -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "http://sdmx.istat.it/SDMXWS/rest/data/41_983/.F..." >filtro_esempio01.csv
```

Si otterrà un CSV con filtrati 145.000 record, sul totale di 435.000.

Tra i campi anche `ITTER107` (è il terzo), che è quello del codice comunale ISTAT. Se voglio quindi ottenere i dati sugli incidenti stradali con feriti, nella città di Palermo (codice comunale ISTAT `082053`)- filtro `.F.082053..` - il comando sarà:

```bash
curl -kL -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "http://sdmx.istat.it/SDMXWS/rest/data/41_983/.F.082053.." >filtro_esempio02.csv
```

Sono 18 record, uno per ogni anno (questo dataset espone dati soltanto aggregati per anno). Si possono inserire più valori per lo stesso campo, separandoli con il carattere `+`. Se ad esempio si vogliono aggiungere anche gli incidenti con feriti, del comune di Bari (codice ISTAT `072006`) - filtro `.F.082053+072006..` - il comando sarà:

```bash
curl -kL -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "http://sdmx.istat.it/SDMXWS/rest/data/41_983/.F.082053+072006.." >filtro_esempio03.csv
```

Il ultimo una *query* i cui aggiungere un `queryStringParameters`, in particolare `startPeriod`, ovvero impostare il periodo a partire dal quale si vogliono dati. Si possono usare date in formato `ISO8601` e se quindi si vogliono i dati a partire dall'anno 2015, il comando sarà:

```bash
curl -kL -H "Accept: application/vnd.sdmx.data+csv;version=1.0.0" "http://sdmx.istat.it/SDMXWS/rest/data/41_983/?startPeriod=2015" >./filtro_esempio04.csv
```

# Note

Questa guida è stata redatta **leggendo** la **documentazione** - non di ISTAT - presente **in altri siti** che documentano l'accesso REST a servizi SDMX. Il primo da cui siamo partiti è la [guida delle API](https://data.oecd.org/api/sdmx-json-documentation/) di accesso ai dati de l'"Organisation for Economic Co-operation and Development" (OECD).<br>
Se userete queste API, l'invito è quello di approfondire tramite una o più delle risorse in [sitografia](#sitografia).

Abbiamo fatto **pochi** **test** e verifiche, quindi non sappiamo se tutto funziona bene.

**Non è possibile sempre usare tutti i filtri**, perché alcuni dei *dataflow* sono già un sottoinsieme. Ad esempio nel caso del dataset di esempio usato, quello sugli incidenti stradali, non è possibile usare il primo filtro, quello delle frequenze perché sono dati che a monte sono raggruppati per anno.

In ultimo, la cosa più importante: **chiediamo a ISTAT di documentare l'accesso alle loro API in modalità RESTful**.

# Sitografia
- I.Stat data warehouse [http://dati.istat.it/](http://dati.istat.it/);
- Pagina dei Web Service di ISTAT https://www.istat.it/it/metodi-e-strumenti/web-service-sdmx;
- Registro delle meta informazione dei dati statistici di diffusione di ISTAT in formato SDMX http://sdmx.istat.it/sdmxMetaRepository/;
- "How to build a rest query to retrieve eurostat data" https://ec.europa.eu/eurostat/web/sdmx-web-services/a-few-useful-points;
- "sdmx-rest Tips for consumers" https://github.com/sdmx-twg/sdmx-rest/wiki/Tips-for-consumers;
- "SDMX Technical Standards Working Group" https://github.com/sdmx-twg;
- "SDMX - SDMX 2.1 Web services guidelines 2013" https://sdmx.org/wp-content/uploads/SDMX_2-1-1-SECTION_07_WebServicesGuidelines_2013-04.pdf

---

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Licenza Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />Questa guida è distribuita con Licenza <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribuzione 4.0 Internazionale</a>.

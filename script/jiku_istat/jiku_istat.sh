#!/bin/bash

### requisiti ###
# jq, https://github.com/jqlang/jq
# miller, https://miller.readthedocs.io/en/6.13.0/
### requisiti ###

# Attiva opzioni per rendere lo script più robusto
set -x          # Mostra i comandi eseguiti
set -e          # Termina lo script in caso di errori
set -u          # Termina se vengono usate variabili non definite
set -o pipefail # Fa fallire una pipeline se qualsiasi comando fallisce

# Funzione di logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Controllo presenza tool necessari
for cmd in curl jq mlr; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log "ERROR: $cmd non è installato"
        exit 1
    fi
done

# Ottieni il percorso assoluto della directory dello script
folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Pulizia cartella tmp se esiste e creazione delle directory necessarie
rm -rf "${folder}"/tmp
mkdir -p "${folder}"/tmp
mkdir -p "${folder}"/../../data/jiku_istat

log "Download dati ISTAT..."
# Verifica che l'URL risponda e scarica i dati dai flussi dati SDMX dell'ISTAT
if ! curl -kL "https://esploradati.istat.it/SDMXWS/rest/v2/structure/dataflow/IT1/*/1.0" > "${folder}"/tmp/dati.json || [ ! -s "${folder}"/tmp/dati.json ]; then
    log "ERROR: Download fallito"
    exit 1
fi

# Estrai le informazioni rilevanti dai dati e normalizza la struttura
if ! cat "${folder}"/tmp/dati.json | jq -c '.data.dataflows[]|{id:.id,enName:.names.en,itName:.names.it,structure:.structure}' | mlr --jsonl put '$structure=sub(sub($structure,".+:",""),"\(.+","");' then rename structure,refId > "${folder}"/tmp/istatcats.jsonl; then
    log "ERROR: Elaborazione dati fallita"
    exit 1
fi

# Alcune query di esempio commentate
#jq '[.data.dataflows[] | select(.structure == "urn:sdmx:org.sdmx.infomodel.datastructure.DataStructure=IT1:DCIS_RICPOPRES2011(1.0)")]' "${folder}"/dati.json > "${folder}"/DCIS_RICPOPRES2011.json
#jq '[.data.dataflows[] | select(.name == "Toscana")]' "${folder}"/dati.json > "${folder}"/Toscana.json

# Verifica validità dei dati scaricati: controlla il numero minimo di righe attese
if [ "$(wc -l <"${folder}"/tmp/istatcats.jsonl)" -le 100 ]; then
    log "ERROR: Il file contiene meno di 100 righe"
    exit 1
fi

log "Creazione CSV..."
# Estrai i nomi in italiano dei dataset e crea un CSV senza intestazioni
mlr --ijsonl --ocsv --quote-all --headerless-csv-output cut -f itName then uniq -a "${folder}"/tmp/istatcats.jsonl >"${folder}"/tmp/istatcats.csv

# Copia il file nella directory dei dati finali
cp "${folder}"/tmp/istatcats.csv "${folder}"/../../data/jiku_istat/istatcats.csv

log "Creazione JSON..."
# Rinomina il campo id in dataflowId e aggiungi l'URL per ottenere i metadati
mlr -I --jsonl --from "${folder}"/tmp/istatcats.jsonl rename id,dataflowId then put '$getMetadataURL="https://esploradati.istat.it/METADATA_API/api/getMetadata?metadataSetId=MDS_DIFF_REPORT&reportId=".$refId'

# Estrai e formatta i campi rilevanti in formato JSON
mlr --ijsonl --ojson cut -o -f dataflowId,refId,enName,itName,getMetadataURL "${folder}"/tmp/istatcats.jsonl >"${folder}"/../../data/jiku_istat/istatcats.json

log "Operazioni completate con successo"

# Estrazione refId univoci per ottenere le descrizioni
mlr --j2n cut -f refId then uniq -a then sort -t 1 "${folder}"/../../data/jiku_istat/istatcats.json > "${folder}"/tmp/ref_id.txt

# Crea un file di test con solo i primi 3 ID (utile per debugging)
<"${folder}"/tmp/ref_id.txt head -n 3 > "${folder}"/tmp/ref_id_3.txt

# Se il file delle descrizioni esiste già, lo elimina
if [ -f "${folder}"/tmp/descrizioni.jsonl ]; then
    rm "${folder}"/tmp/descrizioni.jsonl
fi

# Per ogni refId, scarica i metadati e estrai la descrizione in italiano
while IFS= read -r line; do
    # Scarica metadata per l'ID corrente e estrai la descrizione in italiano
    curl -kL "https://esploradati.istat.it/METADATA_API/api/getMetadata?metadataSetId=MDS_DIFF_REPORT&reportId=${line}" | \
        jq -c '{"refId":"'"${line}"'","descrizione":.data.metadataSets[0].reports[0].attributeSet.reportedAttributes[0].attributeSet.reportedAttributes[0].texts.it}' >> "${folder}"/tmp/descrizioni.jsonl
done < "${folder}"/tmp/ref_id.txt

# Ordina le descrizioni per refId
mlr -I --jsonl sort -t refId "${folder}"/tmp/descrizioni.jsonl

# Salva le descrizioni nella directory dei dati finali
cp "${folder}"/tmp/descrizioni.jsonl "${folder}"/../../data/jiku_istat/descrizioni.jsonl

# Converti il file JSON in formato JSONL (una entry JSON per riga)
jq -c '.[]' "${folder}"/../../data/jiku_istat/istatcats.json > "${folder}"/../../data/jiku_istat/istatcats.jsonl

# Unisci le descrizioni con i metadati dei dataset utilizzando refId come chiave
mlr --jsonl join -j refId -f "${folder}"/../../data/jiku_istat/istatcats.jsonl then unsparsify then sort -t refId,dataflowId "${folder}"/../../data/jiku_istat/descrizioni.jsonl > "${folder}"/tmp.jsonl

# Converti il risultato finale da JSONL a JSON per la pubblicazione
mlr --ijsonl --ojson cat "${folder}"/tmp.jsonl > "${folder}"/../../data/jiku_istat/istatcats.json

# Pulizia finale: rimuove tutti i file temporanei
find "${folder}"/tmp -type f -delete

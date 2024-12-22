#!/bin/bash

set -x
set -e
set -u
set -o pipefail

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

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Pulizia cartella tmp se esiste
rm -rf "$folder"/tmp
mkdir -p "$folder"/tmp
mkdir -p "$folder"/../../data/jiku_istat

log "Download dati ISTAT..."
# verifica che l'URL risponda e scarica i dati
if ! curl -kL "https://esploradati.istat.it/SDMXWS/rest/v2/structure/dataflow/IT1/*/1.0" | tee >(wc -c >/dev/null || { log "ERROR: Download fallito"; exit 1; }) | jq -c '.data.dataflows[]|{id:.id,enName:.names.en,itName:.names.it,structure:.structure}' | mlr --jsonl put '$structure=sub(sub($structure,".+:",""),"\(.+","");' then rename structure,refId >"$folder"/tmp/istatcats.jsonl; then
    log "ERROR: Elaborazione dati fallita"
    exit 1
fi

# verifica numero minimo righe
if [ "$(wc -l <"$folder"/tmp/istatcats.jsonl)" -le 100 ]; then
    log "ERROR: Il file contiene meno di 100 righe"
    exit 1
fi

log "Creazione CSV..."
mlr --ijsonl --ocsv --quote-all --headerless-csv-output cut -f itName then uniq -a "$folder"/tmp/istatcats.jsonl >"$folder"/tmp/istatcats.csv

cp "$folder"/tmp/istatcats.csv "$folder"/../../data/jiku_istat/istatcats.csv

log "Creazione JSON..."
mlr -I --jsonl --from "$folder"/tmp/istatcats.jsonl rename id,dataflowId then put '$getMetadataURL="https://esploradati.istat.it/METADATA_API/api/getMetadata?metadataSetId=MDS_DIFF_REPORT&reportId=".$refId'

mlr --ijsonl --ojson cut -o -f dataflowId,refId,enName,itName,getMetadataURL "$folder"/tmp/istatcats.jsonl >"$folder"/../../data/jiku_istat/istatcats.json

log "Operazioni completate con successo"

# Pulizia finale
rm -rf "$folder"/tmp

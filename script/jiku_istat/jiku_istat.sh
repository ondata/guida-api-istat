#!/bin/bash

### requisiti ###
# miller, https://miller.readthedocs.io/
### requisiti ###

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/tmp

mkdir -p "$folder"/../../data/jiku_istat

# verifica che l'URL risponda e scarica i dati, se non risponde esci dallo script
curl -kL "https://esploradati.istat.it/SDMXWS/rest/v2/structure/dataflow/IT1/*/1.0" | tee >(wc -c >/dev/null || exit 1) | jq -c '.data.dataflows[]|{id:.id,enName:.names.en,itName:.names.it,structure:.structure}' | mlr --jsonl put '$structure=sub(sub($structure,".+:",""),"\(.+","");' then rename structure,refId >"$folder"/tmp/istatcats.jsonl

# verifica che "$folder"/tmp/istatcats.jsonl abbia più di 100 righe, se non ha più di 100 righe esci dallo script
[ "$(wc -l <"$folder"/tmp/istatcats.jsonl)" -gt 100 ] || exit 1

# estrai elenco dei nomi dei dataflow
mlr --ijsonl --ocsv --quote-all --headerless-csv-output cut -f itName then uniq -a "$folder"/tmp/istatcats.jsonl >"$folder"/tmp/istatcats.csv

cp "$folder"/tmp/istatcats.csv "$folder"/../../data/jiku_istat/istatcats.csv

# crea json dei dataflow, come richiesti da jiku
mlr -I --jsonl --from "$folder"/tmp/istatcats.jsonl rename id,dataflowId then put '$enURL="https://esploradati.istat.it/RefMeta/template/GenericMetadataTemplate.html?nodeId=DW&metadataSetId=MDS_DIFF_REPORT&reportId=".$refId."&lang=en&BaseUrlMDA=https://esploradati.istat.it/METADATA_API"' then put '$itUrl="https://esploradati.istat.it/RefMeta/template/GenericMetadataTemplate.html?nodeId=DW&metadataSetId=MDS_DIFF_REPORT&reportId=".$refId."&lang=it&BaseUrlMDA=https://esploradati.istat.it/METADATA_API"'

mlr --ijsonl --ojson cut -o -f dataflowId,refId,enName,itName,enURL,itUrl "$folder"/tmp/istatcats.jsonl >"$folder"/../../data/jiku_istat/istatcats.json

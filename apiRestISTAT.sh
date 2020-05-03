#!/bin/bash

### requisiti ###
# xq https://github.com/kislyuk/yq
# jq https://github.com/stedolan/jq
# miller https://github.com/johnkerl/miller
### requisiti ###

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

### estrai info sui metadati di base ###

for i in categorisation categoryscheme codelist conceptscheme contentconstraint dataflow datastructure; do
  if [[ ! -f "$folder"/rawdata/"$i".xml ]]; then
    curl -kL "http://sdmx.istat.it/SDMXWS/rest/$i/IT1" >"$folder"/rawdata/"$i".xml
  fi
done

# crea tabella delle datastructure
xq <"$folder"/rawdata/datastructure.xml . >"$folder"/processing/datastructure.json
jq <"$folder"/processing/datastructure.json '.["message:Structure"]["message:Structures"]["structure:DataStructures"]["structure:DataStructure"][]|{iddatastructure:.["@id"],descrizione:.["common:Name"][0]["#text"]}' | mlr --j2c cat >"$folder"/processing/datastructure.csv

# crea tabella dataflow
xq <"$folder"/rawdata/dataflow.xml . >"$folder"/processing/dataflow.json
jq <"$folder"/processing/dataflow.json '.["message:Structure"]["message:Structures"]["structure:Dataflows"]["structure:Dataflow"][]|{iddataflow:.["@id"],descrizione:.["common:Name"][0]?["#text"],iddatastructure:.["structure:Structure"].Ref["@id"]}' | mlr --j2c cat >"$folder"/processing/dataflow.csv

### esplora il DSD DCIS_INCIDMORFER_COM ###

datastructure="DCIS_INCIDMORFER_COM"

# crea cartella raccolata dati
mkdir -p "$folder"/rawdata/"$datastructure"
mkdir -p "$folder"/processing/"$datastructure"

# scarica info datastructure
curl -kL "http://sdmx.istat.it/SDMXWS/rest/datastructure/all/$datastructure" >"$folder"/rawdata/"$datastructure"/datastructure.xml
xq <"$folder"/rawdata/"$datastructure"/datastructure.xml . >"$folder"/processing/"$datastructure"/datastructure.json

# estrai dimesioni della datastructure
jq <"$folder"/processing/"$datastructure"/datastructure.json -r '.["message:Structure"]["message:Structures"]["structure:DataStructures"]["structure:DataStructure"]["structure:DataStructureComponents"]["structure:DimensionList"]["structure:Dimension"][]["structure:LocalRepresentation"]["structure:Enumeration"].Ref["@id"]' >"$folder"/processing/"$datastructure"/DimensionList.txt

# estrai tabelle lista valori dimensioni
while read p; do
  xq <"$folder"/rawdata/codelist.xml '.["message:Structure"]["message:Structures"]["structure:Codelists"]["structure:Codelist"][]|select(.["@id"] =="'"$p"'")' | jq '[{id:.["@id"],dimensionName:.["common:Name"][0]["#text"],dimensionValueID:[.["structure:Code"][]["@id"]],dimensionValueDescription:[.["structure:Code"][]["common:Name"][0]["#text"]]}]' | mlr --j2c reshape -r ":" -o item,value then nest --explode --values --across-fields --nested-fs ":" -f item then reshape -s item_1,value then cut -x -f item_2 >"$folder"/processing/"$datastructure"/Dimension_"$p".csv
done <"$folder"/processing/"$datastructure"/DimensionList.txt

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

mlr -I --csv put -S '$URL="http://dati.istat.it/Index.aspx?DataSetCode=".$iddatastructure' "$folder"/processing/dataflow.csv

### esplora il DSD DCIS_INCIDMORFER_COM ###

datastructure="DCIS_POPRES1"

# crea cartella raccolata dati
mkdir -p "$folder"/rawdata/"$datastructure"
mkdir -p "$folder"/processing/"$datastructure"

# scarica info datastructure
curl -kL "http://sdmx.istat.it/SDMXWS/rest/datastructure/all/$datastructure" >"$folder"/rawdata/"$datastructure"/datastructure.xml
xq <"$folder"/rawdata/"$datastructure"/datastructure.xml . >"$folder"/processing/"$datastructure"/datastructure.json

# estrai dimesioni della datastructure
jq <"$folder"/processing/"$datastructure"/datastructure.json -r '.["message:Structure"]["message:Structures"]["structure:DataStructures"]["structure:DataStructure"]["structure:DataStructureComponents"]["structure:DimensionList"]["structure:Dimension"][]["structure:LocalRepresentation"]["structure:Enumeration"].Ref["@id"]' >"$folder"/processing/"$datastructure"/DimensionList.txt

# estrai tabelle lista valori dimensioni
x=1
while read p; do
  xq <"$folder"/rawdata/codelist.xml '.["message:Structure"]["message:Structures"]["structure:Codelists"]["structure:Codelist"][]|select(.["@id"] =="'"$p"'")' | jq '[{id:.["@id"],dimensionName:.["common:Name"][0]["#text"],dimensionValueID:[.["structure:Code"][]["@id"]],dimensionValueDescription:[.["structure:Code"][]["common:Name"][0]["#text"]]}]' | mlr --j2c reshape -r ":" -o item,value then nest --explode --values --across-fields --nested-fs ":" -f item then reshape -s item_1,value then cut -x -f item_2 >"$folder"/processing/"$datastructure"/"$x"_Dimension_"$p".csv
  x=$(( $x + 1 ))
done <"$folder"/processing/"$datastructure"/DimensionList.txt


# estrai lista delle dimensioni
<"$folder"/rawdata/codelist.xml xq -r '.["message:Structure"]["message:Structures"]["structure:Codelists"]["structure:Codelist"][]["@id"]' >"$folder"/processing/DimensionList.txt

mkdir -p mkdir -p "$folder"/processing/DimensionList

<<commento
while read p; do
  xq <"$folder"/rawdata/codelist.xml '.["message:Structure"]["message:Structures"]["structure:Codelists"]["structure:Codelist"][]|select(.["@id"] =="'"$p"'")' | jq '[{id:.["@id"],dimensionName:.["common:Name"][0]["#text"],dimensionValueID:[.["structure:Code"][]["@id"]],dimensionValueDescription:[.["structure:Code"][]["common:Name"][0]["#text"]]}]' | mlr --j2c reshape -r ":" -o item,value then nest --explode --values --across-fields --nested-fs ":" -f item then reshape -s item_1,value then cut -x -f item_2 >"$folder"/processing/DimensionList/"$p".csv
done <"$folder"/processing/DimensionList.txt
commento

<"$folder"/rawdata/codelist.json jq '[.["message:Structure"]["message:Structures"]["structure:Codelists"]["structure:Codelist"][]|{id:.["@id"],etichetta:.["common:Name"][0]?["#text"]}]' | mlr --j2c cat >"$folder"/processing/codelist.csv

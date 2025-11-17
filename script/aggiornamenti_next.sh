#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/../risorse

URL="https://www.istat.it/js/rsssep.php"
dataflow="https://esploradati.istat.it/SDMXWS/rest/dataflow/IT1"
URLbase="http://dati.istat.it/Index.aspx?DataSetCode="

# leggi la risposta HTTP del sito
code=$(curl -s -kL -o /dev/null -w '%{http_code}' "$URL")

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then
  curl -kL "$URL" | xq '.rss.channel.item' | mlr --j2c cut -x -r -f ":" then sort -r pubDate >"$folder"/rawdata/tmp_aggiornamenti.csv
  cp "$folder"/rawdata/tmp_aggiornamenti.csv "$folder"/../risorse/aggiornamenti.csv
  dos2unix "$folder"/../risorse/aggiornamenti.csv

  # download the dataflows
  curl -kL "$dataflow" >"$folder"/rawdata/tmp_dataflow.xml

  # extract id and name from dataflows
  <"$folder"/rawdata/tmp_dataflow.xml xq -c '."message:Structure"."message:Structures"."structure:Dataflows"."structure:Dataflow"[]|{id:."structure:Structure".Ref."@id",code:."@id"}' >"$folder"/rawdata/tmp_dataflow.jsonl

  # convert jsonl to csv
  mlr --j2c label id,guid "$folder"/rawdata/tmp_dataflow.jsonl >"$folder"/rawdata/tmp_dataflow.csv

  # add the name of the dataset to SDMX info
  mlr --csv join --ul -j guid -f "$folder"/../risorse/aggiornamenti.csv then unsparsify  then sort -r pubDate "$folder"/rawdata/tmp_dataflow.csv >"$folder"/rawdata/tmp_aggiornamenti.csv

  # mv the tmp file to the final file
  mv "$folder"/rawdata/tmp_aggiornamenti.csv "$folder"/../risorse/aggiornamenti.csv

  # create the CSV source for ogr2ogr
  mlr --csv put '$guid="https://esploradati.istat.it/databrowser/#/it/dw/IT1,".$guid."_DF_".$id.",1.0";$link=$guid' then cut -x -f id "$folder"/../risorse/aggiornamenti.csv >"$folder"/../risorse/tmp_rss.csv

  # build the RSS
  ogr2ogr  -f geoRSS  -dsco TITLE="Associazione onData | Aggiornamento dataset SDMX IStat" -dsco LINK="https://ondata.github.io/guida-api-istat/risorse/sdmx.rss" -dsco DESCRIPTION="Un feed RSS sugli aggiornamenti dei dataset rilasciati attraverso il web service SDMX del data warehouse I.Stat"  "$folder"/../risorse/sdmx.rss "$folder"/../risorse/tmp_rss.csv -oo AUTODETECT_TYPE=YES
fi


#https://esploradati.istat.it/databrowser/#/it/dw/IT1,101_12_DF_DCSP_PREZZIAGR_1,1.0

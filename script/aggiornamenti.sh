#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/../risorse

URL="https://www.istat.it/js/rsssep.php"

# leggi la risposta HTTP del sito
code=$(curl -s -kL -o /dev/null -w '%{http_code}' "$URL")

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then
  curl -kL "$URL" | xq '.rss.channel.item' | mlr --j2c cut -x -r -f ":" then sort -r pubDate >"$folder"/rawdata/tmp_aggiornamenti.csv
  cp "$folder"/rawdata/tmp_aggiornamenti.csv "$folder"/../risorse/aggiornamenti.csv
  dos2unix "$folder"/../risorse/aggiornamenti.csv

  mlr --csv put '$guid="https://trigger.it/".$guid;$link=$guid' "$folder"/../risorse/aggiornamenti.csv >"$folder"/../risorse/tmp_rss.csv

  ogr2ogr  -f geoRSS  -dsco TITLE="Aggiornamento dati ISTAT" -dsco LINK="https://ondata.github.io/guida-api-istat/risorse/sdmx.rss" -dsco DESCRIPTION="Un feed per sapere quando c'è un aggiornamento sulle basi ISTAT"  "$folder"/../risorse/sdmx.rss "$folder"/../risorse/tmp_rss.csv -oo AUTODETECT_TYPE=YES
fi



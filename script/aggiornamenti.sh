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
code=$(curl -s -L -o /dev/null -w '%{http_code}' "$URL")

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then
  curl -kL "$URL" | xq '.rss.channel.item' | mlr --j2c cut -x -r -f ":" then sort -f pubDate >"$folder"/rawdata/tmp_aggiornamenti.csv
  cp "$folder"/rawdata/tmp_aggiornamenti.csv "$folder"/../risorse/aggiornamenti.csv
  dos2unix "$folder"/../risorse/aggiornamenti.csv
fi

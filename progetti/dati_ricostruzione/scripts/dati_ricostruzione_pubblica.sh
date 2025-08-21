#!/bin/bash
# Script per l'elaborazione dati Excel "privata" (raw -> interim -> processed).

# Impostazioni di sicurezza
set -x
set -e
set -u
set -o pipefail

# Percorso dello script
folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

nome="pubblica"

# Creazione directory di output per dati intermedi e processati
mkdir -p "${folder}"/../data/interim
mkdir -p "${folder}"/../data/processed
mkdir -p "${folder}"/../data/interim/pubblica

# Elaborazione file Excel "pubblica" (raw -> interim)
find "${folder}"/../data/raw -type f -iname "*Pubblici*.xlsx" | while read -r file; do
  echo "Processing file: $file"

  # Estrazione e filtro fogli Excel rilevanti
  qsv excel -Q --sheet 0 "$file" >"${folder}"/../data/interim/pubblica/"${nome}".csv

  duckdb --csv -c "select * from read_csv_auto('$folder/../data/interim/pubblica/${nome}.csv', normalize_names=true,all_varchar=true);" >"${folder}"/../data/processed/tmp.csv

  mv "${folder}"/../data/processed/tmp.csv "${folder}"/../data/processed/"${nome}.csv"
done

# rimuovi stringa "(vuoto)"
sed -i 's/(vuoto)//gI' "${folder}"/../data/processed/"${nome}.csv"
sed -i 's/NULL//gI' "${folder}"/../data/processed/"${nome}.csv"

mlr -I -S --csv clean-whitespace then put '
  if (is_null($cup)) {
    $url_opencup = $cup
  } else {
    $url_opencup = "https://www.opencup.gov.it/portale/it/web/opencup/home/progetto/-/cup/".$cup
  }
' "${folder}"/../data/processed/"${nome}.csv"

# Download e preparazione dei dati geografici ISTAT
if [ -f "${folder}"/../data/interim/nomi_geografici_istat.csv ]; then
  echo "esiste già"
else
  curl -kL "https://situas-servizi.istat.it/publish/reportspooljson?pfun=74&pdata=04/11/2025" | jq -c '.resultset[]|{provincia:.SIGLA_AUTOMOBILISTICA,comune_istat:.COMUNE,popolazione_residente:.POP_RES,pro_com_t:.PRO_COM_T,area_kmq:.AREA_KMQ}' | mlr --ijsonl --ocsv cat >"${folder}"/../data/interim/nomi_geografici_istat.csv
fi

# Correggi alcuni nomi
while read -r line; do
  prov=$(echo "$line" | jq -r '.prov')
  comune=$(echo "$line" | jq -r '.comune')
  comune_corretto=$(echo "$line" | jq -r '.comune_corretto')
  echo "Correggendo comune: $comune in $comune_corretto"

  mlr -I -S --csv put 'if ($comune == "'"$comune"'") {$comune = "'"$comune_corretto"'";$prov="'"$prov"'"}else{$comune=$comune;$prov=$prov}' "${folder}"/../data/processed/"${nome}.csv"
done <"${folder}"/../data/raw/correzioni_comuni_pubblica.jsonl

tometo_tomato -v "${folder}"/../data/processed/"${nome}.csv" "${folder}"/../data/interim/nomi_geografici_istat.csv -j prov,provincia -j comune,comune_istat -s -a "pro_com_t" -o "${folder}"/../data/interim/pubblica_istat_comuni.csv

duckdb --csv -c "
SELECT a.*, b.pro_com_t
FROM read_csv_auto('${folder}/../data/processed/${nome}.csv') AS a
LEFT JOIN read_csv_auto('${folder}/../data/interim/pubblica_istat_comuni.csv') AS b
ON a.comune = b.comune
AND a.prov = b.prov;
" > "${folder}"/../data/interim/tmp.csv

mv "${folder}"/../data/interim/tmp.csv "${folder}"/../data/processed/"${nome}".csv

sed -i 's/NULL//g' "${folder}"/../data/processed/"${nome}.csv"

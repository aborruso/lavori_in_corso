#!/bin/bash
# Script per l'elaborazione dati Excel "privata" (raw -> interim -> processed).

# Impostazioni di sicurezza
set -x
set -e
set -u
set -o pipefail

# Percorso dello script
folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Creazione directory di output per dati intermedi e processati
mkdir -p "$folder"/../data/interim
mkdir -p "$folder"/../data/processed
mkdir -p "$folder"/../data/interim/privata

# Elaborazione file Excel "privata" (raw -> interim)
find "$folder"/../data/raw -type f -iname "*privata*.xlsx" | while read -r file; do
    echo "Processing file: $file"

    # Estrazione e filtro fogli Excel rilevanti
    qsv excel --metadata json "${file}" | jq -r '.sheet[].name' | grep -v -iP "(foglio|profe)" | while read -r sheet; do
        echo "Processing sheet: $sheet"

        # Normalizzazione nome foglio per coerenza
        sheet_lower=$(echo "$sheet" | tr '[:upper:]' '[:lower:]')

        # Estrazione dati foglio a CSV (interim)
        qsv excel -Q --sheet "$sheet" "${file}" > "$folder"/../data/interim/privata/"${sheet_lower}.csv"

        # Trasformazione CSV con DuckDB (interim -> processed)
        duckdb --csv -c "select * from read_csv_auto('$folder/../data/interim/privata/${sheet_lower}.csv', normalize_names=true,all_varchar=true);" > "$folder"/../data/processed/tmp.csv

        # Spostamento file trasformato in interim (sovrascrittura)
        mv "$folder"/../data/processed/tmp.csv "$folder"/../data/interim/privata/"${sheet_lower}.csv"
    done
done

# Unione dei file CSV intermedi in un unico file consolidato
mlr --csv unsparsify "$folder"/../data/interim/privata/*.csv > "$folder"/../data/interim/privata.csv

# Rimozione delle stringhe 'null' dal file consolidato
sed -i 's/null//gI' "$folder"/../data/interim/privata.csv

# Trasformazioni finali con DuckDB (tipi di dato e pulizia regione)
duckdb --csv -c "
SELECT
  *
  REPLACE (
    numero_fascicolo::VARCHAR AS numero_fascicolo,
    CASE
      WHEN regione = '11' THEN 'MARCHE'
      ELSE regione
    END AS regione
  )
FROM read_csv(
  '$folder/../data/interim/privata.csv',
  sample_size = -1
);" > "$folder"/../data/interim/tmp.csv

mv "$folder"/../data/interim/tmp.csv "$folder"/../data/interim/privata.csv

# Ulteriore pulizia delle stringhe 'null' dopo le trasformazioni DuckDB
sed -i 's/null//gI' "$folder"/../data/interim/privata.csv

# Correzione specifica di un nome comune
sed -i 's/PIEVEBOVIGLIANA/Valfornace/gI' "$folder"/../data/interim/privata.csv


# Estrazione e normalizzazione dei nomi geografici unici dal file privata.csv
mlr --csv --from "$folder"/../data/interim/privata.csv cut -o -f provincia,comune then put '$provincia=toupper($provincia);$comune=toupper($comune)' then uniq -a > "$folder"/../data/interim/nomi_geografici.csv

# Download e preparazione dei dati geografici ISTAT
curl -kL "https://situas-servizi.istat.it/publish/reportspooljson?pfun=74&pdata=04/11/2025" | jq -c '.resultset[]|{provincia:.SIGLA_AUTOMOBILISTICA,comune_istat:.COMUNE,popolazione_residente:.POP_RES,pro_com_t:.PRO_COM_T,area_kmq:.AREA_KMQ}' | mlr --ijsonl --ocsv cat > "$folder"/../data/interim/nomi_geografici_istat.csv

# Normalizzazione del separatore decimale per l'area in kmq
mlr -I --csv --from "$folder"/../data/interim/nomi_geografici_istat.csv put '$area_kmq=sub($area_kmq,",",".")'

# Corrispondenza fuzzy tra nomi geografici locali e ISTAT
csvmatch "$folder"/../data/interim/nomi_geografici.csv "$folder"/../data/interim/nomi_geografici_istat.csv --fields1 provincia comune --fields2 provincia comune_istat --fuzzy levenshtein -r 0.9 -i -a -n --join left-outer --output '1*' 2.comune_istat 2.area_kmq 2.popolazione_residente 2.pro_com_t --enc1 utf-8 --enc2 utf-8 > "$folder"/../data/interim/nomi_geografici_match.csv

# Copia del file di corrispondenza nella directory processed
cp "$folder"/../data/interim/nomi_geografici_match.csv "$folder"/../data/processed/nomi_geografici_match.csv

# Normalizzazione del nome del comune nel file privata.csv
mlr -I --csv put '$comune=toupper($comune)' "$folder"/../data/interim/privata.csv

# Unione dei dati privati con le informazioni geografiche ISTAT (output finale)
mlr --csv join --ul -j provincia,comune -f "$folder"/../data/interim/privata.csv then unsparsify "$folder"/../data/interim/nomi_geografici_match.csv > "$folder"/../data/processed/privata.csv

#!/bin/bash
# Script per l'elaborazione dati Excel "privata" (raw -> interim -> processed).

# Impostazioni di sicurezza
set -x
set -e
set -u
set -o pipefail

# Percorso dello script
folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Creazione directory di output
mkdir -p "$folder"/../data/interim
mkdir -p "$folder"/../data/processed
mkdir -p "$folder"/../data/interim/privata

# Elaborazione file Excel "privata"
find "$folder"/../data/raw -type f -iname "*privata*.xlsx" | while read -r file; do
    echo "Processing file: $file"

    # Estrazione e filtro fogli Excel
    qsv excel --metadata json "${file}" | jq -r '.sheet[].name' | grep -v -iP "(foglio|profe)" | while read -r sheet; do
        echo "Processing sheet: $sheet"

        # Normalizzazione nome foglio
        sheet_lower=$(echo "$sheet" | tr '[:upper:]' '[:lower:]')

        # Estrazione dati foglio a CSV (interim)
        qsv excel -Q --sheet "$sheet" "${file}" > "$folder"/../data/interim/privata/"${sheet_lower}.csv"

        # Trasformazione CSV con DuckDB (processed)
        duckdb --csv -c "select * from read_csv_auto('$folder/../data/interim/privata/${sheet_lower}.csv', normalize_names=true,all_varchar=true);" > "$folder"/../data/processed/tmp.csv

        # Spostamento file trasformato
        mv "$folder"/../data/processed/tmp.csv "$folder"/../data/interim/privata/"${sheet_lower}.csv"
    done
done


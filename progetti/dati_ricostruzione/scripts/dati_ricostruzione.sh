#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/../data/interim
mkdir -p "$folder"/../data/processed
mkdir -p "$folder"/../data/interim/privata

find "$folder"/../data/raw -type f -iname "*privata*.xlsx" | while read -r file; do
    echo "Processing file: $file"

    qsv excel --metadata json "${file}" | jq -r '.sheet[].name' | grep -v -iP "(foglio|profe)" | while read -r sheet; do
        echo "Processing sheet: $sheet"

        sheet_lower=$(echo "$sheet" | tr '[:upper:]' '[:lower:]')

        qsv excel -Q --sheet "$sheet" "${file}" > "$folder"/../data/interim/privata/"${sheet_lower}.csv"

        duckdb --csv -c "select * from read_csv_auto('$folder/../data/interim/privata/${sheet_lower}.csv', normalize_names=true,all_varchar=true);" > "$folder"/../data/processed/tmp.csv

        mv "$folder"/../data/processed/tmp.csv "$folder"/../data/interim/privata/"${sheet_lower}.csv"
    done
done


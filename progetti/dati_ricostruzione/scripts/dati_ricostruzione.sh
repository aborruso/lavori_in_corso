#!/bin/bash
#
# Script per l'elaborazione dei dati Excel "privata" dal formato raw a CSV
# e successiva trasformazione/normalizzazione tramite DuckDB.
# I dati vengono spostati da 'raw' a 'interim' e poi 'processed'.

# --- Impostazioni di sicurezza e debug ---
set -x # Stampa i comandi eseguiti (utile per debug)
set -e # Esce immediatamente se un comando fallisce
set -u # Tratta le variabili non impostate come errore
set -o pipefail # Fa fallire una pipeline se un comando intermedio fallisce

# --- Definizione delle directory ---
# Ottiene il percorso assoluto della directory corrente dello script.
# Questo assicura che gli script possano essere eseguiti da qualsiasi posizione.
folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Creazione delle directory di output ---
# Crea le directory 'interim' e 'processed' all'interno della struttura 'data'
# del progetto, se non esistono già.
mkdir -p "$folder"/../data/interim
mkdir -p "$folder"/../data/processed
# Crea una sottodirectory specifica per i dati "privata" all'interno di interim.
mkdir -p "$folder"/../data/interim/privata

# --- Elaborazione dei file Excel "privata" ---
# Trova tutti i file .xlsx (case-insensitive) che contengono "privata" nel nome
# all'interno della directory 'data/raw' e li processa uno per uno.
find "$folder"/../data/raw -type f -iname "*privata*.xlsx" | while read -r file; do
    echo "Processing file: $file"

    # Estrae i nomi dei fogli dal file Excel usando qsv e jq.
    # Filtra i nomi dei fogli per escludere quelli che contengono "foglio" o "profe" (case-insensitive).
    qsv excel --metadata json "${file}" | jq -r '.sheet[].name' | grep -v -iP "(foglio|profe)" | while read -r sheet; do
        echo "Processing sheet: $sheet"

        # Converte il nome del foglio in minuscolo per l'uso come nome file CSV.
        sheet_lower=$(echo "$sheet" | tr '[:upper:]' '[:lower:]')

        # Estrae i dati dal foglio Excel specificato e li salva come file CSV
        # nella directory 'data/interim/privata'.
        qsv excel -Q --sheet "$sheet" "${file}" > "$folder"/../data/interim/privata/"${sheet_lower}.csv"

        # Carica il file CSV appena creato in DuckDB, normalizza i nomi delle colonne
        # e imposta tutte le colonne come VARCHAR. L'output viene reindirizzato a un file temporaneo.
        duckdb --csv -c "select * from read_csv_auto('$folder/../data/interim/privata/${sheet_lower}.csv', normalize_names=true,all_varchar=true);" > "$folder"/../data/processed/tmp.csv

        # Sposta il file temporaneo (ora elaborato da DuckDB) sovrascrivendo il CSV originale
        # nella directory 'data/interim/privata'. Questo completa la fase di trasformazione
        # e normalizzazione per il singolo foglio.
        mv "$folder"/../data/processed/tmp.csv "$folder"/../data/interim/privata/"${sheet_lower}.csv"
    done
done


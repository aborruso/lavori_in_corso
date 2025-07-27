# Copilot Instructions for `dati_ricostruzione`

## Architettura e flusso dati
- Il progetto gestisce dati di ricostruzione tramite una pipeline di file Excel (raw) → CSV (interim) → CSV normalizzati (processed).
- I dati sono organizzati in `data/raw/` (Excel originali), `data/interim/privata/` (CSV estratti per foglio), e `data/processed/` (output temporanei).
- Lo script principale è `scripts/dati_ricostruzione.sh`, che automatizza l'estrazione e la normalizzazione dei dati.

## Workflow principale
- Per elaborare i dati, eseguire lo script bash:
  ```bash
  bash scripts/dati_ricostruzione.sh
  ```
- Lo script cerca file Excel con "privata" nel nome, estrae i fogli rilevanti (escludendo quelli con nomi tipo "foglio" o "profe"), li converte in CSV e li normalizza tramite DuckDB.
- I file CSV finali sono salvati in `data/interim/privata/` con nomi foglio in minuscolo.

## Convenzioni e pattern
- I nomi dei fogli vengono convertiti in minuscolo per uniformità.
- I file temporanei DuckDB sono sempre chiamati `tmp.csv` e sovrascritti ad ogni ciclo.
- I dati processati vengono spostati nella stessa cartella dei CSV interim, sovrascrivendo il file.
- Tutti i percorsi sono relativi alla posizione dello script.

## Dipendenze esterne
- Utilizza `qsv` per estrazione da Excel, `jq` per parsing JSON, `duckdb` per normalizzazione CSV.
- Assicurarsi che questi tool siano installati e disponibili nel PATH.

## Note e raccomandazioni
- Non ci sono test automatici o notebook di esempio al momento.
- La documentazione principale è in `README.md` e il log delle attività in `LOG.md`.
- Per aggiungere nuovi workflow, seguire la struttura esistente e documentare in `README.md`.

## Esempio di struttura dati
```
data/
  raw/         # Excel originali
  interim/
    privata/   # CSV per foglio
  processed/   # Output temporanei
scripts/
  dati_ricostruzione.sh
```

## Contatti e log
- Aggiornamenti e note di sviluppo sono in `LOG.md`.

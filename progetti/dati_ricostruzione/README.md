# dati_ricostruzione

Questo progetto si occupa della ricostruzione e dell'elaborazione di dati specifici.

## Struttura della Cartella

- `data/`: Contiene i dati grezzi, intermedi e processati.
- `docs/`: Documentazione specifica del progetto.
- `scripts/`: Script per l'elaborazione dei dati.
- `notebooks/`: Notebook Quarto per analisi e visualizzazioni.

## Note file RAW

- la colonna regione per le Marche contiene il valore `11` e non `MARCHE` come le altre regioni
- Il comune `PIEVEBOVIGLIANA` (che in realtà è un municipio) viene corretto in `Valfornace` dallo script `dati_ricostruzione.sh`.

## Output dello script `sintesi.sh`

Lo script `sintesi.sh` genera i seguenti file CSV nella cartella `data/processed/`:

- [`spesa_totale_per_unita_amministrativa.csv`](data/processed/spesa_totale_per_unita_amministrativa.csv): contiene la somma degli importi richiesti, concessi e liquidati per regione, provincia e comune ISTAT.
- [`spesa_pro_capite_per_comune.csv`](data/processed/spesa_pro_capite_per_comune.csv): contiene la spesa per abitante per comune ISTAT, basandosi sulla popolazione residente.
- [`spesa_per_kmq_per_comune.csv`](data/processed/spesa_per_kmq_per_comune.csv): contiene la spesa per chilometro quadrato per comune ISTAT, basandosi sull'area geografica.
- [`spesa_media_per_tipologia_intervento.csv`](data/processed/spesa_media_per_tipologia_intervento.csv): contiene la spesa media per le diverse tipologie di intervento.
- [`distribuzione_stati_interventi_per_comune.csv`](data/processed/distribuzione_stati_interventi_per_comune.csv): conta il numero di interventi per stato (es. Chiuso, Aperto) per ogni comune ISTAT.
- [`impatto_superbonus_spesa_totale.csv`](data/processed/impatto_superbonus_spesa_totale.csv): confronta la spesa totale per gli interventi con e senza Superbonus.

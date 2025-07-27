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

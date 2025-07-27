## LOG - Progetto dati_ricostruzione

### 2025-07-27
- Inizializzazione del file di log per tracciare gli avanzamenti del subprogetto 'dati_ricostruzione'.
- Esplorazione iniziale del file 'data/interim/privata.csv'.
- Identificazione e risoluzione di problemi di tipo di dato per le colonne degli importi ('importo_richiesto', 'importo_concesso', 'importo_liquidato').
- Gestione del valore '11' nella colonna 'regione', mappandolo a 'MARCHE'.
- Discussione e implementazione della gestione dei valori negativi in 'importo_liquidato' (impostati a 0).
- Utilizzo dell'opzione 'all_varchar=TRUE' per una lettura robusta del CSV.
- Riesame della tabella 'privata.csv' dopo la pulizia e rigenerazione, confermando i miglioramenti e identificando criticità residue (valori nulli in colonne sensibili e importo_liquidato negativo).
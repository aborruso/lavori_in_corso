# PRD - L'Impatto della Digitalizzazione sulla Democrazia Diretta in Italia

## 1. Introduzione e Obiettivo

### Contesto

Gli strumenti di democrazia diretta in Italia, come i referendum e le leggi di iniziativa popolare, sono stati storicamente frenati da processi di raccolta firme analogici, complessi e onerosi. L'introduzione della piattaforma digitale `firmereferendum.giustizia.it` a partire dal 1° gennaio 2024 ha segnato una svolta, semplificando drasticamente la partecipazione dei cittadini.

Questo progetto si propone di analizzare e quantificare l'impatto di questa innovazione.

### Obiettivo

L'obiettivo è realizzare un'analisi comparativa basata sui dati per misurare come la digitalizzazione abbia influenzato il numero, la tipologia, le tematiche e l'esito delle iniziative referendarie e di legge popolare in Italia, confrontando lo scenario pre e post 2024.

## 2. Fonti Dati

L'analisi si baserà sulle seguenti fonti:

1.  **Dati Storici (Pre-2024)**:
    *   Archivi parlamentari (Camera e Senato) per le proposte di legge di iniziativa popolare.
    *   Dati storici sui referendum abrogativi (es. Ministero dell'Interno, ISTAT).
    *   Fonti aggregate e verificate come Wikipedia, basate su documentazione ufficiale.

2.  **Dati Attuali (Post-2024)**:
    *   **Fonte Primaria**: Sezione *Open Data* della piattaforma del Ministero della Giustizia, costantemente monitorata e archiviata da `onData`: [firmereferendum.giustizia.it/referendum/open](https://firmereferendum.giustizia.it/referendum/open).
    *   I dati includono informazioni su iniziative in corso e concluse, numero di sottoscrittori, date di inizio e fine raccolta.

## 3. Strumenti di Analisi

Per garantire un'analisi efficiente, riproducibile e trasparente, verranno utilizzati i seguenti strumenti *open source*:

*   **DuckDB**: Per l'analisi interattiva e l'interrogazione di file di dati strutturati (CSV, JSONL, Parquet). Sarà lo strumento principale per calcolare statistiche aggregate, join e analisi complesse.
*   **Miller**: Per le operazioni di pre-processing, pulizia, trasformazione e manipolazione dei dati direttamente da riga di comando.

## 4. Struttura del Progetto

Il progetto seguirà la struttura standard per garantire ordine e riproducibilità:

```
/
├── data/
│   ├── raw/      # Dati grezzi scaricati dalle fonti
│   ├── interim/  # Dati intermedi dopo pulizia e trasformazione
│   └── processed/# Dati finali pronti per la sintesi
├── scripts/      # Script (bash, DuckDB SQL) per l'ETL e l'analisi
├── docs/         # Documentazione di progetto (include questo PRD)
├── README.md     # Descrizione del progetto e istruzioni
└── LOG.md        # Diario delle decisioni e dei progressi
```

## 5. Fasi del Progetto

1.  **Raccolta Dati**:
    *   Acquisire i dati storici e organizzarli in formato CSV o JSONL.
    *   Impostare uno *script* per scaricare periodicamente i dati aggiornati dalla piattaforma ministeriale e archiviarli nella cartella `data/raw`.

2.  **Esplorazione e Pulizia (EDA)**:
    *   Utilizzare `miller` e `duckdb` per ispezionare i dati grezzi, identificare anomalie, formati incoerenti e valori mancanti.
    *   Creare *script* per pulire e standardizzare i dati (es. normalizzazione delle date, pulizia dei nomi).

3.  **Analisi Comparativa**:
    *   Confrontare il numero di iniziative presentate prima e dopo il 2024.
    *   Analizzare la velocità di raccolta firme per le iniziative digitali.
    *   Classificare le iniziative per tematica e confrontarne la distribuzione nei due periodi.
    *   Verificare il tasso di successo (raggiungimento del quorum di firme) e l'esito finale (ammissibilità, discussione parlamentare, approvazione).

4.  **Sintesi e Risultati**:
    *   Produrre tabelle aggregate e file CSV nella cartella `data/processed` che riassumano i risultati dell'analisi.
    *   Redigere un report finale nel `README.md` che illustri i punti salienti emersi.

## 6. Risultati Attesi

*   Un *dataset* pulito e aggregato sull'evoluzione della democrazia diretta in Italia.
*   *Script* riproducibili per l'intero processo di analisi.
*   Un report chiaro e basato sui dati che risponda alla domanda principale: qual è stato l'impatto misurabile della digitalizzazione sulla democrazia diretta in Italia?

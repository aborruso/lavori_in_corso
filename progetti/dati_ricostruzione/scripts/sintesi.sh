#!/bin/bash
# Script per la generazione di report di sintesi sui dati di ricostruzione.

# Impostazioni di sicurezza
set -x
set -e
set -u
set -o pipefail

# Percorso dello script
folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Percorso della directory dei dati processati
processed_dir="$folder"/../data/processed

# 1. Spesa Totale per Unità Amministrativa
# Calcola la somma degli importi richiesti, concessi e liquidati per regione, provincia e comune.
duckdb --csv -c "
SELECT
    regione,
    provincia,
    comune,
    SUM(importo_richiesto) AS totale_richiesto,
    SUM(importo_concesso) AS totale_concesso,
    SUM(GREATEST(importo_liquidato, 0)) AS totale_liquidato
FROM read_csv('$processed_dir/privata.csv', sample_size=-1)
GROUP BY regione, provincia, comune
ORDER BY regione, provincia, comune;
" > "$processed_dir"/spesa_totale_per_unita_amministrativa.csv

# 2. Spesa Pro Capite per Comune
# Calcola la spesa per abitante per comune, basandosi sulla popolazione residente.
duckdb --csv -c "
SELECT
    regione,
    provincia,
    comune,
    popolazione_residente,
    SUM(importo_richiesto) / popolazione_residente AS richiesto_pro_capite,
    SUM(importo_concesso) / popolazione_residente AS concesso_pro_capite,
    SUM(GREATEST(importo_liquidato, 0)) / popolazione_residente AS liquidato_pro_capite
FROM read_csv('$processed_dir/privata.csv', sample_size=-1)
GROUP BY regione, provincia, comune, popolazione_residente
HAVING popolazione_residente > 0
ORDER BY regione, provincia, comune;
" > "$processed_dir"/spesa_pro_capite_per_comune.csv

# 3. Spesa per Chilometro Quadrato per Comune
# Calcola la spesa per chilometro quadrato per comune, basandosi sull'area geografica.
duckdb --csv -c "
SELECT
    regione,
    provincia,
    comune,
    area_kmq,
    SUM(importo_richiesto) / area_kmq AS richiesto_per_kmq,
    SUM(importo_concesso) / area_kmq AS concesso_per_kmq,
    SUM(GREATEST(importo_liquidato, 0)) / area_kmq AS liquidato_per_kmq
FROM read_csv('$processed_dir/privata.csv', sample_size=-1)
GROUP BY regione, provincia, comune, area_kmq
HAVING area_kmq > 0
ORDER BY regione, provincia, comune;
" > "$processed_dir"/spesa_per_kmq_per_comune.csv

# 4. Spesa Media per Tipologia di Intervento
# Calcola la spesa media per le diverse tipologie di intervento.
duckdb --csv -c "
SELECT
    tipologia_intervento,
    AVG(importo_richiesto) AS media_richiesto,
    AVG(importo_concesso) AS media_concesso,
    AVG(GREATEST(importo_liquidato, 0)) AS media_liquidato
FROM read_csv('$processed_dir/privata.csv', sample_size=-1)
GROUP BY tipologia_intervento
ORDER BY tipologia_intervento;
" > "$processed_dir"/spesa_media_per_tipologia_intervento.csv

# 5. Distribuzione degli Stati degli Interventi per Comune
# Conta il numero di interventi per stato (es. Chiuso, Aperto) per ogni comune.
duckdb --csv -c "
SELECT
    regione,
    provincia,
    comune,
    stato,
    COUNT(*) AS numero_interventi
FROM read_csv('$processed_dir/privata.csv', sample_size=-1)
GROUP BY regione, provincia, comune, stato
ORDER BY regione, provincia, comune, stato;
" > "$processed_dir"/distribuzione_stati_interventi_per_comune.csv

# 6. Impatto del Superbonus sulla Spesa Totale
# Confronta la spesa totale per gli interventi con e senza Superbonus.
duckdb --csv -c "
SELECT
    flag_superbonus,
    SUM(importo_richiesto) AS totale_richiesto,
    SUM(importo_concesso) AS totale_concesso,
    SUM(GREATEST(importo_liquidato, 0)) AS totale_liquidato
FROM read_csv('$processed_dir/privata.csv', sample_size=-1)
GROUP BY flag_superbonus
ORDER BY flag_superbonus;
" > "$processed_dir"/impatto_superbonus_spesa_totale.csv

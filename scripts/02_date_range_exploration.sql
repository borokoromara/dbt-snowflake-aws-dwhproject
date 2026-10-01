/*
===============================================================================
Exploration des plages de dates
===============================================================================
Objectif :
    - Déterminer les bornes temporelles des principales données.
    - Comprendre la période historique couverte par les ventes.
    - Identifier les âges minimum et maximum des clients.

Fonctions SQL utilisées :
    - MIN()
    - MAX()
    - DATEDIFF()
    - CURRENT_DATE()
===============================================================================
*/


-- Déterminer la première et la dernière date de commande
-- ainsi que la durée totale de la période couverte en mois
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(
        MONTH,
        MIN(order_date),
        MAX(order_date)
    ) AS order_range_months
FROM DWH_DEV.GOLD.FCT_SALES;


-- Déterminer la date de naissance du client le plus âgé et du plus jeune
-- ainsi que leur âge actuel
SELECT
    MIN(birth_date) AS oldest_birth_date,
    DATEDIFF(
        YEAR,
        MIN(birth_date),
        CURRENT_DATE()
    ) AS oldest_age,
    MAX(birth_date) AS youngest_birth_date,
    DATEDIFF(
        YEAR,
        MAX(birth_date),
        CURRENT_DATE()
    ) AS youngest_age
FROM DWH_DEV.GOLD.DIM_CUSTOMER;

/*
===============================================================================
Analyse cumulative
===============================================================================
Objectif :
    - Calculer les totaux cumulés et les moyennes des indicateurs clés.
    - Suivre l'évolution des ventes dans le temps.
    - Analyser les tendances à long terme.

Fonctions SQL utilisées :
    - Fonctions de fenêtrage : SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculer le chiffre d'affaires annuel
-- et son cumul dans le temps,
-- ainsi que le prix moyen annuel et sa moyenne cumulative.

SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_sales,
    AVG(avg_price) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS moving_average_price
FROM (
    SELECT
        DATE_TRUNC('YEAR', order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM DWH_DEV.GOLD.FCT_SALES
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('YEAR', order_date)
) t
ORDER BY order_date;

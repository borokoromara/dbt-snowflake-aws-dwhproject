/*
===============================================================================
Analyse de segmentation des données
===============================================================================
Objectif :
    - Regrouper les produits selon leur coût.
    - Identifier la répartition des produits par tranche de prix de revient.

Fonctions SQL utilisées :
    - CASE : définir les tranches de coût.
    - GROUP BY : regrouper les produits par segment.
===============================================================================
*/

/*
Segmenter les produits selon leur coût et compter le nombre de produits
dans chaque tranche.
*/

WITH product_segments AS (

    SELECT
        product_id,
        product_key,
        product_name,
        product_cost,
        CASE
            WHEN product_cost < 100 THEN 'Below 100'
            WHEN product_cost < 500 THEN '100-500'
            WHEN product_cost <= 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM DWH_DEV.GOLD.DIM_PRODUCT

)

SELECT
    cost_range,
    COUNT(product_id) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

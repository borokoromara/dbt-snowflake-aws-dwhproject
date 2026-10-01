/*
===============================================================================
Analyse des classements
===============================================================================
Objectif :
    - Classer les produits et les clients selon leurs performances.
    - Identifier les produits générant le plus ou le moins de chiffre d'affaires.
    - Identifier les clients générant le plus de chiffre d'affaires.
    - Identifier les clients ayant passé le moins de commandes.

Fonctions SQL utilisées :
    - RANK()
    - GROUP BY
    - ORDER BY
    - LIMIT
===============================================================================
*/


-- ============================================================================
-- 1. Les 5 produits générant le plus de chiffre d'affaires
-- ============================================================================

SELECT
    p.product_id,
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM DWH_DEV.GOLD.FCT_SALES f
LEFT JOIN DWH_DEV.GOLD.DIM_PRODUCT p
    ON p.product_id = f.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_revenue DESC
LIMIT 5;


-- ============================================================================
-- 2. Les 5 produits générant le plus de chiffre d'affaires
--    avec une fonction de classement
-- ============================================================================

SELECT *
FROM (
    SELECT
        p.product_id,
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (
            ORDER BY SUM(f.sales_amount) DESC
        ) AS product_rank
    FROM DWH_DEV.GOLD.FCT_SALES f
    LEFT JOIN DWH_DEV.GOLD.DIM_PRODUCT p
        ON p.product_id = f.product_id
    GROUP BY
        p.product_id,
        p.product_name
) AS ranked_products
WHERE product_rank <= 5
ORDER BY product_rank;


-- ============================================================================
-- 3. Les 5 produits générant le moins de chiffre d'affaires
-- ============================================================================

SELECT
    p.product_id,
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM DWH_DEV.GOLD.FCT_SALES f
LEFT JOIN DWH_DEV.GOLD.DIM_PRODUCT p
    ON p.product_id = f.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_revenue ASC
LIMIT 5;


-- ============================================================================
-- 4. Les 10 clients générant le plus de chiffre d'affaires
-- ============================================================================

SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM DWH_DEV.GOLD.FCT_SALES f
LEFT JOIN DWH_DEV.GOLD.DIM_CUSTOMER c
    ON c.customer_id = f.customer_id
GROUP BY
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================================
-- 5. Les 3 clients ayant passé le moins de commandes
-- ============================================================================

SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM DWH_DEV.GOLD.FCT_SALES f
LEFT JOIN DWH_DEV.GOLD.DIM_CUSTOMER c
    ON c.customer_id = f.customer_id
GROUP BY
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders ASC
LIMIT 3;

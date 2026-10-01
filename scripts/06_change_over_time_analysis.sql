/*
===============================================================================
Analyse de l'évolution dans le temps
===============================================================================
Objectif :
    - Suivre l'évolution des ventes dans le temps.
    - Identifier les tendances et variations mensuelles.
    - Analyser l'évolution du nombre de clients et des quantités vendues.
    - Préparer les données nécessaires à une analyse temporelle.

Fonctions SQL utilisées :
    - YEAR()
    - MONTH()
    - DATE_TRUNC()
    - TO_CHAR()
    - SUM()
    - COUNT()
    - COUNT(DISTINCT)
===============================================================================
*/


-- ============================================================================
-- 1. Évolution des ventes par année et par mois
-- ============================================================================

SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(quantity) AS total_quantity
FROM DWH_DEV.GOLD.FCT_SALES
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year,order_month;


-- ============================================================================
-- 2. Évolution des ventes par mois avec DATE_TRUNC()
-- ============================================================================

SELECT
    DATE_TRUNC('MONTH', order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(quantity) AS total_quantity
FROM DWH_DEV.GOLD.FCT_SALES
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('MONTH', order_date)
ORDER BY order_month;


-- ============================================================================
-- 3. Évolution des ventes par mois avec un format lisible
-- ============================================================================

SELECT
    TO_CHAR(DATE_TRUNC('MONTH', order_date),'YYYY-MON') AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(quantity) AS total_quantity
FROM DWH_DEV.GOLD.FCT_SALES
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('MONTH', order_date)
ORDER BY DATE_TRUNC('MONTH', order_date);

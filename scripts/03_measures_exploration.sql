/*
===============================================================================
Exploration des mesures (indicateurs clés)
===============================================================================
Objectif :
    - Calculer les principaux indicateurs du Data Warehouse.
    - Obtenir rapidement une vision globale de l'activité.
    - Identifier d'éventuelles anomalies dans les données.

Fonctions SQL utilisées :
    - COUNT()
    - COUNT(DISTINCT)
    - SUM()
    - AVG()
===============================================================================
*/


-- Calculer le chiffre d'affaires total
SELECT
    SUM(sales_amount) AS total_sales
FROM DWH_DEV.GOLD.FCT_SALES;


-- Calculer la quantité totale vendue
SELECT
    SUM(quantity) AS total_quantity
FROM DWH_DEV.GOLD.FCT_SALES;


-- Calculer le prix moyen de vente
SELECT
    AVG(price) AS avg_price
FROM DWH_DEV.GOLD.FCT_SALES;


-- Compter le nombre total de lignes de ventes
SELECT
    COUNT(*) AS total_sales_lines
FROM DWH_DEV.GOLD.FCT_SALES;


-- Compter le nombre total de commandes distinctes
SELECT
    COUNT(DISTINCT order_number) AS total_orders
FROM DWH_DEV.GOLD.FCT_SALES;


-- Compter le nombre total de produits
-- product_id est utilisé car il est unique dans DIM_PRODUCT
SELECT
    COUNT(product_id) AS total_products
FROM DWH_DEV.GOLD.DIM_PRODUCT;


-- Compter le nombre total de clients
SELECT
    COUNT(customer_key) AS total_customers
FROM DWH_DEV.GOLD.DIM_CUSTOMER;


-- Compter le nombre de clients ayant effectué au moins une commande
SELECT
    COUNT(DISTINCT customer_id) AS total_customers_with_orders
FROM DWH_DEV.GOLD.FCT_SALES;


/*
===============================================================================
Rapport synthétique des principaux indicateurs
===============================================================================
*/

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM DWH_DEV.GOLD.FCT_SALES
UNION ALL
SELECT 'Total Quantity', SUM(quantity)FROM DWH_DEV.GOLD.FCT_SALES
UNION ALL 
SELECT 'Average Price', AVG(price) FROM DWH_DEV.GOLD.FCT_SALES
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM DWH_DEV.GOLD.FCT_SALES
UNION ALL
SELECT 'Total Products', COUNT(product_id) FROM DWH_DEV.GOLD.DIM_PRODUCT
UNION ALL 
SELECT 'Total Customers', COUNT(customer_key) FROM DWH_DEV.GOLD.DIM_CUSTOMER
UNION ALL
SELECT 'Customers With Orders', COUNT(DISTINCT customer_id) FROM DWH_DEV.GOLD.FCT_SALES;

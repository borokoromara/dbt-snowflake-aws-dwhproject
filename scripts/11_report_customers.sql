
/*
===============================================================================
Rapport clients
===============================================================================
Objectif :
    - Consolider les principaux indicateurs et comportements des clients.
    - Segmenter les clients selon leur âge et leurs dépenses.
    - Calculer les indicateurs au niveau client :
        - Nombre total de commandes
        - Chiffre d'affaires total
        - Quantité totale achetée
        - Nombre de produits distincts
        - Durée d'activité en mois
    - Calculer les KPI :
        - Récence (mois depuis la dernière commande)
        - Valeur moyenne par commande
        - Dépense mensuelle moyenne

Source :
    - DWH_DEV.GOLD.FCT_SALES
    - DWH_DEV.GOLD.DIM_CUSTOMER
===============================================================================
*/

WITH base_query AS (

    /*
    1) Données de base : informations clients et ventes
    */

    SELECT
        f.order_number,
        f.product_key,
        f.product_id,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(YEAR, c.birth_date, CURRENT_DATE()) AS age
    FROM DWH_DEV.GOLD.FCT_SALES f
    LEFT JOIN DWH_DEV.GOLD.DIM_CUSTOMER  c
        ON c.customer_id = f.customer_id
    WHERE f.order_date IS NOT NULL

),

customer_aggregation AS (

    /*
    2) Agrégation des indicateurs au niveau client
    */

    SELECT
        customer_key,
        customer_id,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_id) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(
            MONTH,
            MIN(order_date),
            MAX(order_date)
        ) AS lifespan
    FROM base_query
    GROUP BY
        customer_key,
        customer_id,
        customer_name,
        age

)

 /*
 3) Segmentation clients et calcul des KPI
 */

SELECT
    customer_key,
    customer_id,
    customer_name,
    age,
    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,
    CASE
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    last_order_date,
    DATEDIFF(MONTH,last_order_date,CURRENT_DATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    -- Valeur moyenne par commande
    total_sales / NULLIF(total_orders, 0) AS avg_order_value,
    -- Dépense mensuelle moyenne
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / NULLIF(lifespan, 0)
    END AS avg_monthly_spen
FROM customer_aggregation

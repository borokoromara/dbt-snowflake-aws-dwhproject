/*
===============================================================================
Rapport produits
===============================================================================
Objectif :
    - Consolider les principaux indicateurs et comportements des produits.
    - Segmenter les produits selon leur chiffre d'affaires.
    - Calculer les indicateurs au niveau produit :
        - Nombre total de commandes
        - Chiffre d'affaires total
        - Quantité totale vendue
        - Nombre de clients distincts
        - Durée d'activité en mois
    - Calculer les KPI :
        - Récence (mois depuis la dernière vente)
        - Revenu moyen par commande
        - Revenu mensuel moyen

Sources :
    - DWH_DEV.GOLD.FCT_SALES
    - DWH_DEV.GOLD.DIM_PRODUCT
===============================================================================
*/

WITH base_query AS (

    /*
    1) Données de base : informations produits et ventes
    */

    SELECT
        f.order_number,
        f.order_date,
        f.customer_id,
        f.sales_amount,
        f.quantity,
        f.product_id,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.product_cost

    FROM DWH_DEV.GOLD.FCT_SALES f
    LEFT JOIN DWH_DEV.GOLD.DIM_PRODUCT p
        ON f.product_id = p.product_id
    WHERE f.order_date IS NOT NULL

),

product_aggregations AS (

    /*
    2) Agrégation des indicateurs au niveau produit
    */

    SELECT
        product_id,
        product_key,
        product_name,
        category,
        subcategory,
        product_cost,
        DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_id) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND(AVG(sales_amount / NULLIF(quantity, 0)),1) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_id,
        product_key,
        product_name,
        category,
        subcategory,
        product_cost

)

 /*
 3) Segmentation des produits et calcul des KPI
 */

SELECT
    product_id,
    product_key,
    product_name,
    category,
    subcategory,
    product_cost,

    last_sale_date,

    DATEDIFF(
        MONTH,
        last_sale_date,
        CURRENT_DATE()
    ) AS recency_in_months,

    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    -- Revenu moyen par commande (AOR)
    total_sales / NULLIF(total_orders, 0) AS avg_order_revenue,

    -- Revenu mensuel moyen
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / NULLIF(lifespan, 0)
    END AS avg_monthly_revenue

FROM product_aggregations

/*
===============================================================================
Analyse des performances (annuelle et évolution d'une année à l'autre)
===============================================================================
Objectif :
    - Mesurer les performances annuelles des produits.
    - Comparer les ventes de chaque produit à sa moyenne annuelle.
    - Analyser l'évolution des ventes par rapport à l'année précédente.
    - Identifier les tendances à la hausse ou à la baisse.

Fonctions SQL utilisées :
    - YEAR() : extraire l'année d'une date.
    - LAG() : accéder à la valeur de la ligne précédente.
    - AVG() OVER() : calculer une moyenne par produit.
    - CASE : définir des conditions d'analyse.
===============================================================================
*/

/*
Analyser les performances annuelles des produits en comparant leurs ventes
à leur moyenne annuelle et à celles de l'année précédente.
*/

WITH yearly_product_sales AS (

    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM DWH_DEV.GOLD.FCT_SALES f
    LEFT JOIN DWH_DEV.GOLD.DIM_PRODUCT p ON f.product_id = p.product_id
    WHERE f.order_date IS NOT NULL
      AND f.product_id IS NOT NULL
      GROUP BY
          YEAR(f.order_date),
          p.product_name

)

SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER ( PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (
    PARTITION BY product_name) AS diff_avg,
    CASE
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    -- Analyse de l'évolution annuelle (Year-over-Year)
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year ) < 0 THEN 'Decrease'
        WHEN LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) IS NULL THEN 'No Previous Year'
        ELSE 'No Change'
    END AS py_change

FROM yearly_product_sales
ORDER BY
    product_name,
    order_year;

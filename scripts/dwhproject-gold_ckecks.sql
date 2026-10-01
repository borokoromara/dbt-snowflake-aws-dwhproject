--1. Vérification des clients
SELECT
    f.*
FROM DWH_DEV.GOLD.FCT_SALES f
LEFT JOIN DWH_DEV.GOLD.DIM_CUSTOMER c
    ON c.customer_id = f.customer_id
WHERE c.customer_id IS NULL;--Résultat attendu : 0 ligne.

--2. Vérification des produits
SELECT
    f.*
FROM DWH_DEV.GOLD.FCT_SALES f
LEFT JOIN DWH_DEV.GOLD.DIM_PRODUCT p
    ON p.product_id = f.product_id
WHERE f.product_id IS NOT NULL
  AND p.product_id IS NULL; ---Résultat attendu : 0 ligne.


  ---3. Check complet client + produit : le contrôle d'intégrité global 

  SELECT
    f.*
FROM DWH_DEV.GOLD.FCT_SALES f
LEFT JOIN DWH_DEV.GOLD.DIM_CUSTOMER c
    ON c.customer_id = f.customer_id
LEFT JOIN DWH_DEV.GOLD.DIM_PRODUCT p
    ON p.product_id = f.product_id
WHERE c.customer_id IS NULL
   OR (
        f.product_id IS NOT NULL
        AND p.product_id IS NULL
   );
   --Résultat attendu : 0 ligne

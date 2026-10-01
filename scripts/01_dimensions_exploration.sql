/*
===============================================================================
Exploration des dimensions
===============================================================================
Objectif :
    - Explorer la structure et le contenu des tables de dimensions
    - Identifier les valeurs distinctes disponibles

Fonctions SQL utilisées :
    - DISTINCT
    - ORDER BY
===============================================================================
*/


-- Récupérer la liste des valeurs distinctes de statut matrimonial
-- présentes dans la dimension client
SELECT DISTINCT
    marital_status
FROM DWH_DEV.GOLD.DIM_CUSTOMER
ORDER BY marital_status;


-- Récupérer la liste des valeurs distinctes de genre
-- présentes dans la dimension client
SELECT DISTINCT
    gender
FROM DWH_DEV.GOLD.DIM_CUSTOMER
ORDER BY gender;


-- Récupérer la liste des catégories, sous-catégories et produits
-- présents dans la dimension produit
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM DWH_DEV.GOLD.DIM_PRODUCT
ORDER BY
    category,
    subcategory,
    product_name;

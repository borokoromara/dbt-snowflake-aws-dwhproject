# AWS + Snowflake + dbt Data Warehouse

Data Warehouse AWS + Snowflake + dbt

Projet de Data Warehouse moderne construit avec AWS S3, Snowflake et dbt.

L'objectif du projet est de mettre en place une chaîne complète de traitement de données permettant d'ingérer des fichiers CSV provenant de sources CRM et ERP, de les stocker dans AWS S3, de les charger dans Snowflake, puis de les transformer avec dbt jusqu'à un modèle analytique exploitable pour la BI.

Architecture du projet
Sources CRM / ERP
       |
       v
AWS S3 - LANDING
       |
       v
Snowflake - RAW
       |
       v
Snowflake - BRONZE
       |
       v
dbt - SILVER
       |
       v
dbt - GOLD
       |
       v
BI / Analytics
Principes d'architecture

Le projet suit une architecture Medallion :

RAW : données brutes issues de l'ingestion.
BRONZE : données sources structurées et conservées dans leur forme technique.
SILVER : nettoyage, typage, standardisation, déduplication et harmonisation des données.
GOLD : modèle dimensionnel destiné à l'analyse et à la BI.
Technologies utilisées
AWS S3 — stockage des fichiers sources
AWS IAM — gestion des permissions et accès sécurisés
Snowflake — Data Warehouse
dbt Core — transformation et tests des données
Python — environnement d'exécution
Git / GitHub — versionnement du projet
Sources de données

Le projet utilise deux sources principales.

CRM

Les données CRM contiennent :

Clients
Produits
Ventes

Fichiers :

cust_info.csv
prd_info.csv
sales_details.csv
ERP

Les données ERP contiennent :

Informations clients complémentaires
Localisation des clients
Catégories produits

Fichiers :

CUST_AZ12.csv
LOC_A101.csv
PX_CAT_G1V2.csv
Stockage AWS S3

Les fichiers sources sont déposés dans un bucket S3 dédié à l'environnement DEV.

dwh-project-dev-data

Organisation des fichiers :

landing/
├── crm/
│   ├── cust_info.csv
│   ├── prd_info.csv
│   └── sales_details.csv
│
└── erp/
    ├── CUST_AZ12.csv
    ├── LOC_A101.csv
    └── PX_CAT_G1V2.csv

archive/
├── crm/
└── erp/

L'accès de Snowflake à S3 utilise une IAM Role et une Storage Integration Snowflake, sans stocker de credentials AWS dans le code.

Architecture Snowflake

La base de données DEV est :

DWH_DEV

Elle est organisée en quatre schémas :

DWH_DEV
├── RAW
├── BRONZE
├── SILVER
└── GOLD
RAW

La couche RAW correspond aux données directement chargées depuis S3.

Elle conserve la structure des fichiers sources sans transformation métier.

Tables :

CRM_CUSTOMER
CRM_PRODUCT
CRM_SALES

ERP_CUSTOMER
ERP_LOCATION
ERP_PRODUCT_CATEGORY
BRONZE

La couche BRONZE contient les tables sources structurées utilisées comme point d'entrée stable pour dbt.

Tables :

BRZ_CRM_CUSTOMER
BRZ_CRM_PRODUCT
BRZ_CRM_SALES

BRZ_ERP_CUSTOMER
BRZ_ERP_LOCATION
BRZ_ERP_PRODUCT_CATEGORY
Transformation avec dbt

dbt est utilisé pour construire les couches SILVER et GOLD.

Couche STAGING

La couche staging fournit une interface stable entre les tables BRONZE et les transformations dbt.

Modèles CRM :

stg_crm_customer
stg_crm_product
stg_crm_sales

Modèles ERP :

stg_erp_customer
stg_erp_location
stg_erp_product_category

Les modèles staging utilisent les sources dbt :

{{ source('crm', 'BRZ_CRM_CUSTOMER') }}

et :

{{ source('erp', 'BRZ_ERP_CUSTOMER') }}
Couche INTERMEDIATE

La couche intermediate contient les transformations nécessaires à la préparation du modèle analytique.

Modèles :

int_customer
int_product
int_product_category
int_location
int_sales
int_customer

Le modèle client permet notamment de :

filtrer les clés clients invalides ;
supprimer les doublons ;
conserver l'enregistrement le plus récent ;
convertir les types ;
harmoniser les informations CRM et ERP ;
normaliser le genre ;
traiter les dates de naissance invalides.
int_product

Le modèle produit permet notamment de :

convertir les types ;
conserver les différentes versions des produits ;
rattacher les catégories ERP ;
gérer les produits sans catégorie correspondante.
int_sales

Le modèle des ventes permet notamment de :

convertir les dates YYYYMMDD ;
convertir les mesures numériques ;
rattacher les ventes aux versions produits applicables ;
conserver une ligne par ligne de vente source.

Le rattachement produit utilise la date de commande et la version produit disponible à cette date.

Lorsque aucun produit applicable n'est trouvé, product_id reste NULL plutôt que de forcer un rattachement incorrect.

Modèle analytique GOLD

La couche GOLD constitue le modèle destiné à la consommation analytique.

Elle contient trois modèles principaux :

GOLD
├── DIM_CUSTOMER
├── DIM_PRODUCT
└── FCT_SALES
Dimension client
dim_customer

Cette dimension contient les informations principales des clients :

identifiant client ;
clé client ;
prénom ;
nom ;
statut marital ;
genre ;
date de naissance ;
date de création.

La clé métier principale est :

customer_key
Dimension produit
dim_product

Cette dimension contient :

identifiant produit ;
clé produit ;
nom produit ;
coût ;
ligne produit ;
catégorie ;
sous-catégorie ;
maintenance ;
dates de validité.

La clé technique utilisée pour identifier le produit est :

product_id
Table de faits des ventes
fct_sales

La table de faits contient les informations transactionnelles :

commande ;
produit ;
client ;
dates ;
quantité ;
prix ;
montant des ventes.

La clé technique de la ligne de vente est :

sales_key

Elle est construite à partir de :

order_number + product_key
Grain

Le grain de fct_sales est :

Une ligne par ligne de vente source.

Le contrôle effectué sur les données confirme :

60 398 lignes
60 398 lignes de vente distinctes
0 doublon sur order_number + product_key
Montant des ventes

Le champ sales_amount conserve la valeur provenant de la source.

Il n'est pas recalculé systématiquement avec :

quantity × price

car les données sources contiennent certaines différences entre le montant fourni et le calcul quantity × price.

Cette décision permet de préserver la valeur métier provenant de la source.

Qualité des données

Des tests dbt sont définis sur les modèles intermédiaires et Gold.

Les contrôles comprennent notamment :

not_null
unique
relationships
Résultats actuels
Modèles dbt : 14
Tests dbt   : 28

Tests réussis : 28 / 28
Warnings      : 0
Erreurs       : 0

Les contrôles réalisés couvrent notamment :

unicité des clients ;
unicité des produits ;
unicité des lignes de ventes ;
présence des clés obligatoires ;
intégrité référentielle entre les ventes et les dimensions ;
intégrité référentielle des catégories produits.
Sécurité

Le projet applique plusieurs principes de sécurité.

AWS
Utilisation d'une IAM Role pour l'accès Snowflake → S3.
Permissions limitées à la lecture des données nécessaires.
Aucun secret AWS dans le dépôt Git.
Snowflake
Séparation des couches RAW, BRONZE, SILVER et GOLD.
Utilisation d'une Storage Integration pour l'accès S3.
Séparation des environnements DEV et PROD prévue dans l'architecture.
Git

Les fichiers sensibles et fichiers générés sont exclus du dépôt :

.env
.venv/
target/
dbt_packages/
logs/
Structure du projet dbt
dwh_project/
│
├── analyses/
│
├── macros/
│   └── generate_schema_name.sql
│
├── models/
│   │
│   ├── staging/
│   │   ├── crm/
│   │   │   ├── src_crm.yml
│   │   │   ├── stg_crm_customer.sql
│   │   │   ├── stg_crm_product.sql
│   │   │   └── stg_crm_sales.sql
│   │   │
│   │   └── erp/
│   │       ├── src_erp.yml
│   │       ├── stg_erp_customer.sql
│   │       ├── stg_erp_location.sql
│   │       └── stg_erp_product_category.sql
│   │
│   ├── intermediate/
│   │   ├── int_customer.sql
│   │   ├── int_customer.yml
│   │   ├── int_location.sql
│   │   ├── int_location.yml
│   │   ├── int_product.sql
│   │   ├── int_product.yml
│   │   ├── int_product_category.sql
│   │   ├── int_product_category.yml
│   │   ├── int_sales.sql
│   │   └── int_sales.yml
│   │
│   └── marts/
│       ├── dimensions/
│       │   ├── dim_customer.sql
│       │   ├── dim_customer.yml
│       │   ├── dim_product.sql
│       │   └── dim_product.yml
│       │
│       └── facts/
│           ├── fct_sales.sql
│           └── fct_sales.yml
│
├── seeds/
├── snapshots/
├── tests/
├── dbt_project.yml
├── .gitignore
└── README.md
Environnement

L'environnement actuellement opérationnel est :

DEV

Base Snowflake :

DWH_DEV

Warehouse :

WH_DEV_TRANSFORM

Les modèles dbt sont matérialisés en vues :

DWH_DEV.SILVER
DWH_DEV.GOLD
Validation du pipeline

Le pipeline dbt a été exécuté avec succès :

dbt run

Résultat :

14 modèles
14 réussis
0 erreur
0 warning

Les tests ont ensuite été exécutés avec :

dbt test

Résultat :

28 tests
28 réussis
0 erreur
0 warning

Le pipeline DEV est donc actuellement validé de bout en bout.

Évolutions prévues

Les prochaines étapes possibles du projet sont :

mise en place de l'environnement PROD ;
CI/CD avec GitHub Actions ;
automatisation de l'ingestion S3 ;
orchestration des traitements ;
monitoring et observabilité ;
modèles dbt incrémentaux ;
documentation dbt générée automatiquement ;
création d'un dashboard BI ;
mise en place de tests supplémentaires ;
optimisation des coûts et performances Snowflake.
Objectif du projet

Ce projet a pour objectif de démontrer la mise en œuvre d'une architecture Data Engineering moderne intégrant :

AWS
+
Snowflake
+
dbt
+
Git
+
Data Quality

avec une séparation claire entre ingestion, stockage, transformation, qualité des données et exposition analytique.

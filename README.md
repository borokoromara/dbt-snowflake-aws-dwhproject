# AWS + Snowflake + dbt Data Warehouse

Modern Data Warehouse project built with **AWS S3, Snowflake and dbt**.

The project ingests CRM and ERP CSV data from Amazon S3, loads it into Snowflake, transforms it with dbt using a Silver/Gold architecture, and exposes a dimensional model for analytics.

## Architecture

```text
CRM / ERP CSV
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
Technology Stack
AWS S3
AWS IAM
Snowflake
dbt Core
dbt Snowflake adapter
Git / GitHub
Data Sources
CRM
Customer
Product
Sales
ERP
Customer
Location
Product Category
dbt Layers
Staging

The staging layer exposes the Bronze tables through dbt sources and provides a stable interface for transformations.

Models:

stg_crm_customer
stg_crm_product
stg_crm_sales
stg_erp_customer
stg_erp_location
stg_erp_product_category
Intermediate

The intermediate layer performs data cleaning, typing, standardization, deduplication and CRM/ERP harmonization.

Models:

int_customer
int_product
int_product_category
int_location
int_sales
Gold

The Gold layer provides the analytical dimensional model.

Models:

dim_customer
dim_product
fct_sales

fct_sales grain is one row per source sales line, identified by:

order_number + product_key
Data Quality

dbt tests cover:

Not-null constraints
Uniqueness
Referential integrity
Customer relationships
Product relationships

Current validation:

14 dbt models
28 dbt data tests
28/28 tests passing
Environments

Current environment:

DEV

Snowflake database:

DWH_DEV

Schemas:

RAW
BRONZE
SILVER
GOLD
Security

The project follows basic least-privilege principles:

AWS IAM role for Snowflake-to-S3 access
Read-only access to S3 landing data
No credentials stored in the repository
Environment-specific configuration
Secrets excluded through .gitignore
Project Structure
dwh_project/
├── analyses/
├── macros/
├── models/
│   ├── staging/
│   ├── intermediate/
│   └── marts/
├── seeds/
├── snapshots/
├── tests/
├── dbt_project.yml
└── README.md
Status

The DEV data warehouse and dbt transformation pipeline are operational and validated end-to-end.

Future improvements may include:

CI/CD
Production environment
Incremental models
Automated ingestion
Monitoring and observability
BI dashboard
EOF

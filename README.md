## 🧠 Design Principles

This platform is built using modern data engineering best practices:

- **Layered Architecture**
  - RAW → CLEAN → ANALYTICS separation
- **Incremental Processing**
  - Snowflake Streams + Tasks for change data capture
- **Transformation Framework**
  - dbt for modular, testable transformations
- **Infrastructure as Code**
  - Terraform manages all Snowflake resources
- **Security & Governance**
  - Role-based access control (RBAC)
- **Environment Separation**
  - DEV and PRD databases for safe deployment

## 🔐 Roles & Responsibilities

| Role            | Access Level |
|-----------------|-------------|
| ROLE_LOADER     | Insert into RAW |
| ROLE_TRANSFORM  | Full access to CLEAN & ANALYTICS |
| ROLE_ANALYST    | Read-only access to ANALYTICS |

## ⚙️ Tech Stack

- Snowflake (Data Platform)
- dbt (Transformations)
- Terraform (Infrastructure)
- SQL / Python


## 🧪 Running the Project End-to-End

## 🔐 Snowflake Setup

Create a free Snowflake account if you don't already have an account

https://signup.snowflake.com/

Then gather:

snowflake_organization_name  = "YOUR_SNOWFLAKE_ORG_NAME"
snowflake_account_name       = "YOUR_SNOWFLAKE_ACCOUNT_NAME"
snowflake_user               = "YOUR_SNOWFLAKE_USER"
snowflake_password           = "YOUR_SNOWFLAKE_PASSWORD"
snowflake_role               = "ACCOUNTADMIN"

You can find your account identifier in Snowsight:
Admin → Accounts → Locator

Copy terraform.tfvars.example → terraform.tfvars

Update with your credentials

`terraform apply` grants `ROLE_LOADER`, `ROLE_TRANSFORM`, and `ROLE_ANALYST` to the configured `snowflake_user`, so the setup scripts can switch roles without a separate manual grant step.

### 1. Deploy Infrastructure / optional variable default enable_streams_and_tasks = false
terraform init
terraform apply

### 2. Load Sample Data
Run the scripts in /setup:

- 01_reset.sql
- 02_seed_raw_data.sql

### 3. Run Transformations

## dbt Execution Options

### Option 1: Local dbt
Run dbt locally using dbt-snowflake.

dbt run
dbt test

### Option 2: Snowflake Native dbt (Recommended)
Run dbt directly in Snowflake using Snowsight:

1. Go to Data → Projects → dbt Projects
2. Connect to this repository
3. Configure environment
4. Run models

### 4. Validate Outputs

RAW:
SELECT COUNT(*) FROM RAW.BUSINESS_EVENTS;

CLEAN:
SELECT COUNT(*) FROM CLEAN.STG_BUSINESS_EVENTS;

ANALYTICS:
SELECT * FROM ANALYTICS.FCT_BUSINESS_EVENTS;

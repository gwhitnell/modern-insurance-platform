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

### 1. Deploy Infrastructure
terraform init
terraform apply

### 2. Load Sample Data
Run the scripts in /setup:

- 01_reset.sql
- 02_seed_raw_data.sql

### 3. Run Transformations
dbt run
dbt test

### 4. Validate Outputs

RAW:
SELECT COUNT(*) FROM RAW.BUSINESS_EVENTS;

CLEAN:
SELECT COUNT(*) FROM CLEAN.BUSINESS_EVENTS_INCREMENTAL;

ANALYTICS:
SELECT * FROM ANALYTICS.FCT_BUSINESS_EVENTS;
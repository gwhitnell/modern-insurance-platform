## 🧠 Design Principles

This platform is built using modern data engineering best practices:

- **Layered Architecture**
  - RAW → CLEAN → ANALYTICS separation
- **Incremental Processing**
  - Snowflake Streams + Tasks for change data capture
- **Transformation Framework**
  - dbt for modular, testable transformations
- **Infrastructure as Code**
  - Terraform manages Snowflake resources and RAW layer
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

- Git (Source Control)
- Snowflake (Data Platform)
- dbt (Transformations)
- Terraform (Infrastructure)
- SQL / Python


## 🧪 Running the Project End-to-End

## ✅ Prerequisites

Before running the project locally, install:

- Git
- Terraform
- Python 3.10+
- dbt Core with the Snowflake adapter
- A Snowflake account

### Install Git

Ubuntu / WSL:
`sudo apt update && sudo apt install -y git`

macOS:
`brew install git`

Check:
`git --version`

### Install Terraform

Ubuntu / WSL:

```bash
sudo apt update && sudo apt install -y wget gpg lsb-release
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
```

macOS:
`brew tap hashicorp/tap && brew install hashicorp/tap/terraform`

Check:
`terraform --version`

### Install Python And dbt

Create a virtual environment and install dbt:

```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install dbt-core dbt-snowflake
```

Check:
`dbt --version`

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

### 0. Clone Repository

git clone https://github.com/gwhitnell/modern-insurance-platform.git
cd modern_insurance_platform

### 1. Deploy Infrastructure

cd terraform

Copy terraform.tfvars.example → terraform.tfvars

Update with your snowflake credentials

`terraform apply` grants `ROLE_LOADER`, `ROLE_TRANSFORM`, and `ROLE_ANALYST` to the configured `snowflake_user`, so the setup scripts can switch roles without a separate manual grant step.

terraform init
terraform apply

### 2. Load Sample Data
Run the scripts in /setup:

- 01_reset.sql
- 02_seed_raw_data.sql

If incremental required run task in snowflake which will consume resource EXECUTE TASK RAW.BUSINESS_EVENTS_TASK;

Additional info for production in setup/README.md

### 3. Run Transformations

## dbt Execution Options

### Option 1: Local dbt
Run dbt locally using dbt-snowflake.

Create a local dbt profile at `~/.dbt/profiles.yml`.

This project uses the dbt profile name `modern_insurance_platform` from `dbt_project.yml`, so your local `profiles.yml` must contain a matching entry.

Example:

```yaml
modern_insurance_platform:
  outputs:
    dev:
      type: snowflake
      account: YOUR_ACCOUNT_IDENTIFIER
      user: YOUR_USERNAME
      password: YOUR_PASSWORD
      role: ACCOUNTADMIN
      warehouse: MODERN_INSURANCE_PLATFORM_WH
      database: DEV_MODERN_INSURANCE_PLATFORM
      schema: DBT
      threads: 4
    prd:
      type: snowflake
      account: YOUR_ACCOUNT_IDENTIFIER
      user: YOUR_USERNAME
      password: YOUR_PASSWORD
      role: ACCOUNTADMIN
      warehouse: MODERN_INSURANCE_PLATFORM_WH
      database: PRD_MODERN_INSURANCE_PLATFORM
      schema: DBT
      threads: 4
  target: dev
```

How to use it:

- `dbt debug` uses the default target from `target: dev`
- `dbt run` builds into `DEV_MODERN_INSURANCE_PLATFORM`
- `dbt run --target prd` builds into `PRD_MODERN_INSURANCE_PLATFORM`
- `dbt test --target prd` runs tests against PRD

Check your local connection:

```bash
dbt debug
dbt debug --target prd
```

dbt run
dbt test

### Option 2: Snowflake Native dbt (Recommended) -- there are some limitations to trial account because external access is disabled

Run dbt directly in Snowflake using Snowsight:

1. Go to My Worksheets → My Workspace → From Git repository
2. Connect to this repository (May need API integration in snowflake)
3. Configure environment
4. Run models

### 4. Validate Outputs

RAW:
SELECT COUNT(*) FROM RAW.BUSINESS_EVENTS;

CLEAN:
SELECT COUNT(*) FROM CLEAN.STG_BUSINESS_EVENTS;

ANALYTICS:
SELECT * FROM ANALYTICS.FCT_BUSINESS_EVENTS;

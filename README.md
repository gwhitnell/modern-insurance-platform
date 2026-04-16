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

Install Python 3.10+ first:

Ubuntu / WSL:
`sudo apt update && sudo apt install -y python3 python3-venv python3-pip`

macOS:
`brew install python@3.10`

Check:
`python3 --version`

Then create a virtual environment and install dbt:

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

### Demo Security Note

This project is intentionally set up to be easy to bootstrap locally, so the examples below use password authentication, `ACCOUNTADMIN`, and grant the project roles to a single configured user. That keeps the setup simple for a portfolio/demo project and makes it easy to switch roles while loading data and running transformations.

In a more production-oriented implementation, I would tighten this considerably by separating bootstrap/admin access from runtime roles, avoiding broad admin use for dbt execution, reducing destructive privileges in production paths, and using stronger credential handling such as key-pair auth, OAuth, or secret management.

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

cd modern-insurance-platform

### 1. Deploy Infrastructure

cd terraform

Copy terraform.tfvars.example → terraform.tfvars

cp terraform.tfvars.example terraform.tfvars

Update with your snowflake credentials and save

terraform init

terraform apply 

answer 'yes' when prompted

`terraform apply` grants `ROLE_LOADER`, `ROLE_TRANSFORM`, and `ROLE_ANALYST` to the configured `snowflake_user`, so the setup scripts can switch roles without a separate manual grant step.

That single-user role assignment is a convenience for this demo project rather than the pattern I would recommend for a production deployment.

### 2. Load Sample Data
Run the scripts in /setup for dev step first in snowflake worksheets or snowsql:

- 02_seed_raw_data.sql

Additional info for when production promotion happens in setup/README.md

- 04_seed_raw_data.sql

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

Ensure virtual environment activated

source venv/bin/activate

cd modern_insurance_platform/

- `dbt debug` uses the default target from `target: dev`
- `dbt deps` builds dependencies
- `dbt run --full-refresh` builds into `DEV_MODERN_INSURANCE_PLATFORM`
- `dbt test` runs tests

Ensure you are happy dev has run successfully before moving on to production, ensure data setup/ has been run for production

- `dbt run --target prd --full-refresh` builds into `PRD_MODERN_INSURANCE_PLATFORM`
- `dbt test --target prd` runs tests against PRD

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

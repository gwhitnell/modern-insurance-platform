# Terraform Snowflake Baseline

This folder provisions core Snowflake infrastructure for the project:

- `MODERN_INSURANCE_PLATFORM_WH` warehouse
- `DEV_MODERN_INSURANCE_PLATFORM` and `PRD_MODERN_INSURANCE_PLATFORM` databases
- `RAW`, `CLEAN`, `ANALYTICS` schemas in both databases

## Prerequisites

- Terraform `>= 1.6`
- Snowflake user with permissions to create warehouse/databases/schemas

## Run

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your real user/password

terraform init
terraform plan
terraform apply
```

## Notes

- Terraform manages infrastructure objects; dbt manages transformations.
- Keep `terraform.tfvars` local (do not commit credentials).
- `streams/tasks` can be added as Terraform resources in a next iteration after core infra is stable.

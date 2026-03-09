# modern-insurance-platform
Using DBT and Snowflake to build a sample modern insurance platform for learning purposes

Resources:

DBT - For this demonstration we will be using DBT core as it is free in combination with snowflake
https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup

Snowflake - Instructions on getting setup on free trial

## Project Structure

- `models/` dbt models (staging + marts)
- `macros/` dbt macros (including schema naming override)
- `terraform/` Snowflake infrastructure as code (warehouse, env databases, layered schemas)

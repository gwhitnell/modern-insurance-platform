############################################
# SCHEMA USAGE GRANTS
############################################

# --- LOADER: RAW schema only
resource "snowflake_grant_privileges_to_account_role" "loader_raw_usage_dev" {
  account_role_name = snowflake_account_role.loader_role.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.env_db["DEV"].name}.RAW"
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.loader_dev_database_usage,
    snowflake_schema.layer_schema,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "loader_raw_usage_prd" {
  account_role_name = snowflake_account_role.loader_role.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.env_db["PRD"].name}.RAW"
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.loader_prd_database_usage,
    snowflake_schema.layer_schema,
  ]
}

# --- TRANSFORM: CLEAN + ANALYTICS
resource "snowflake_grant_privileges_to_account_role" "transform_clean_usage_dev" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.env_db["DEV"].name}.CLEAN"
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.transform_dev_database_usage,
    snowflake_schema.layer_schema,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "transform_clean_usage_prd" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.env_db["PRD"].name}.CLEAN"
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.transform_prd_database_usage,
    snowflake_schema.layer_schema,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "transform_analytics_usage_dev" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.env_db["DEV"].name}.ANALYTICS"
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.transform_dev_database_usage,
    snowflake_schema.layer_schema,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "transform_analytics_usage_prd" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.env_db["PRD"].name}.ANALYTICS"
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.transform_prd_database_usage,
    snowflake_schema.layer_schema,
  ]
}

# --- ANALYST: ANALYTICS only
resource "snowflake_grant_privileges_to_account_role" "analyst_analytics_usage_dev" {
  account_role_name = snowflake_account_role.analyst_role.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.env_db["DEV"].name}.ANALYTICS"
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.analyst_dev_database_usage,
    snowflake_schema.layer_schema,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "analyst_analytics_usage_prd" {
  account_role_name = snowflake_account_role.analyst_role.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.env_db["PRD"].name}.ANALYTICS"
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.analyst_prd_database_usage,
    snowflake_schema.layer_schema,
  ]
}

############################################
# CREATE PERMISSIONS (TRANSFORM ROLE)
############################################

resource "snowflake_grant_privileges_to_account_role" "transform_create_clean_dev" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["CREATE TABLE", "CREATE VIEW"]

  on_schema {
    schema_name = "${snowflake_database.env_db["DEV"].name}.CLEAN"
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.transform_clean_usage_dev,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "transform_create_clean_prd" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["CREATE TABLE", "CREATE VIEW"]

  on_schema {
    schema_name = "${snowflake_database.env_db["PRD"].name}.CLEAN"
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.transform_clean_usage_prd,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "transform_create_analytics_dev" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["CREATE TABLE", "CREATE VIEW"]

  on_schema {
    schema_name = "${snowflake_database.env_db["DEV"].name}.ANALYTICS"
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.transform_analytics_usage_dev,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "transform_create_analytics_prd" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["CREATE TABLE", "CREATE VIEW"]

  on_schema {
    schema_name = "${snowflake_database.env_db["PRD"].name}.ANALYTICS"
  }

  depends_on = [
    snowflake_grant_privileges_to_account_role.transform_analytics_usage_prd,
  ]
}

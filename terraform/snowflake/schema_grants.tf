############################################
# SCHEMA USAGE GRANTS
############################################

# --- LOADER: RAW schema only
resource "snowflake_grant_privileges_to_account_role" "loader_raw_usage_dev" {
  account_role_name = "ROLE_LOADER"
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.env_db["DEV"].name}.RAW"
  }
}

# --- TRANSFORM: CLEAN + ANALYTICS
resource "snowflake_grant_privileges_to_account_role" "transform_clean_usage_dev" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.env_db["DEV"].name}.CLEAN"
  }
}

resource "snowflake_grant_privileges_to_account_role" "transform_analytics_usage_dev" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.env_db["DEV"].name}.ANALYTICS"
  }
}

# --- ANALYST: ANALYTICS only
resource "snowflake_grant_privileges_to_account_role" "analyst_analytics_usage_dev" {
  account_role_name = "ROLE_ANALYST"
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "${snowflake_database.env_db["DEV"].name}.ANALYTICS"
  }
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
}

resource "snowflake_grant_privileges_to_account_role" "transform_create_analytics_dev" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["CREATE TABLE", "CREATE VIEW"]

  on_schema {
    schema_name = "${snowflake_database.env_db["DEV"].name}.ANALYTICS"
  }
}
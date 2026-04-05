############################################
# DATABASE USAGE GRANTS
############################################

resource "snowflake_grant_privileges_to_account_role" "loader_dev_database_usage" {
  account_role_name = snowflake_account_role.loader_role.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.env_db["DEV"].name
  }

  depends_on = [
    snowflake_account_role.loader_role,
    snowflake_database.env_db,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "transform_dev_database_usage" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.env_db["DEV"].name
  }

  depends_on = [
    snowflake_account_role.transform_role,
    snowflake_database.env_db,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "analyst_dev_database_usage" {
  account_role_name = snowflake_account_role.analyst_role.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.env_db["DEV"].name
  }

  depends_on = [
    snowflake_account_role.analyst_role,
    snowflake_database.env_db,
  ]
}

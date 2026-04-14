resource "snowflake_account_role" "loader_role" {
  name = "ROLE_LOADER"
}

resource "snowflake_account_role" "transform_role" {
  name = "ROLE_TRANSFORM"
}

resource "snowflake_account_role" "analyst_role" {
  name = "ROLE_ANALYST"
}

resource "snowflake_grant_account_role" "loader_to_terraform_user" {
  role_name = snowflake_account_role.loader_role.name
  user_name = var.snowflake_user
}

resource "snowflake_grant_account_role" "transform_to_terraform_user" {
  role_name = snowflake_account_role.transform_role.name
  user_name = var.snowflake_user
}

resource "snowflake_grant_account_role" "analyst_to_terraform_user" {
  role_name = snowflake_account_role.analyst_role.name
  user_name = var.snowflake_user
}

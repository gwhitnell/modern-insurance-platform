resource "snowflake_account_role" "loader_role" {
  name = "ROLE_LOADER"
}

resource "snowflake_account_role" "transform_role" {
  name = "ROLE_TRANSFORM"
}

resource "snowflake_account_role" "analyst_role" {
  name = "ROLE_ANALYST"
}
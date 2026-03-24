resource "snowflake_grant_privileges_to_account_role" "loader_wh" {
  account_role_name = "ROLE_LOADER"
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "transform_wh" {
  account_role_name = "ROLE_TRANSFORM"
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "analyst_wh" {
  account_role_name = "ROLE_ANALYST"
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }
}
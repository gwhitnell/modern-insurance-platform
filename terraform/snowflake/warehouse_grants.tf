resource "snowflake_grant_privileges_to_account_role" "loader_wh" {
  account_role_name = snowflake_account_role.loader_role.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }

  depends_on = [
    snowflake_account_role.loader_role,
    snowflake_warehouse.platform_wh,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "transform_wh" {
  account_role_name = snowflake_account_role.transform_role.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }

  depends_on = [
    snowflake_account_role.transform_role,
    snowflake_warehouse.platform_wh,
  ]
}

resource "snowflake_grant_privileges_to_account_role" "analyst_wh" {
  account_role_name = snowflake_account_role.analyst_role.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = var.warehouse_name
  }

  depends_on = [
    snowflake_account_role.analyst_role,
    snowflake_warehouse.platform_wh,
  ]
}

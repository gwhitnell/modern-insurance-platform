locals {
  env_databases = {
    DEV = var.dev_database_name
    PRD = var.prd_database_name
  }

  schema_matrix = merge([
    for env, db_name in local.env_databases : {
      for schema_name in var.schema_names :
      "${env}_${schema_name}" => {
        database = db_name
        schema   = schema_name
      }
    }
  ]...)
}

resource "snowflake_warehouse" "platform_wh" {
  name                = var.warehouse_name
  warehouse_size      = "XSMALL"
  warehouse_type      = "STANDARD"
  auto_suspend        = 60
  auto_resume         = true
  initially_suspended = true
  comment             = "Primary warehouse for Modern Insurance Platform demo."
}

resource "snowflake_database" "env_db" {
  for_each = local.env_databases

  name    = each.value
  comment = "Managed by Terraform for ${each.key} environment."
}

resource "snowflake_schema" "layer_schema" {
  for_each = local.schema_matrix

  database = each.value.database
  name     = each.value.schema
  comment  = "Managed by Terraform (${each.key})."

  depends_on = [snowflake_database.env_db]
}

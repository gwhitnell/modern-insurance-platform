module "snowflake" {
  source = "./snowflake"

  providers = {
    snowflake = snowflake
  }

  warehouse_name           = var.warehouse_name
  dev_database_name        = var.dev_database_name
  prd_database_name        = var.prd_database_name
  schema_names             = var.schema_names
  snowflake_user           = var.snowflake_user
  enable_streams_and_tasks = var.enable_streams_and_tasks
}

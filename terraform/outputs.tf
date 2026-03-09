output "warehouse_name" {
  value = snowflake_warehouse.platform_wh.name
}

output "database_names" {
  value = [for db in snowflake_database.env_db : db.name]
}

output "schemas_created" {
  value = [for schema_obj in snowflake_schema.layer_schema : "${schema_obj.database}.${schema_obj.name}"]
}

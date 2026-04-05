variable "warehouse_name" {}
variable "dev_database_name" {}
variable "prd_database_name" {}
variable "schema_names" {
  type = list(string)
}
variable "enable_streams_and_tasks" {
  type = bool
}

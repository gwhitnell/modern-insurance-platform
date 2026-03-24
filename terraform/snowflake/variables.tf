variable "warehouse_name" {}
variable "dev_database_name" {}
variable "prd_database_name" {}
variable "schema_names" {
  type = list(string)
}